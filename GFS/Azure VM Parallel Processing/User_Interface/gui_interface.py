# Import module
from tkinter import *
from PIL.ImageFile import ImageFile
from tkcalendar import DateEntry
from tkinter import ttk
import subprocess
from PIL import Image, ImageTk
import sv_ttk
from tkinter import messagebox
from pathlib import Path

# Constants
RESOURCE_GROUP_NAME = "FCAP-Standard_E2ads_v5"
VIRTUAL_MACHINE_NAME = "jumpbox"
VIRTUAL_MACHINE_SCALE_SETS_NAME = "vmscaleset"
current_dir: Path = Path(__file__).parent
VM_IP_PATH: Path = current_dir.parent / "Terraform" / "vm_ip.txt"
FE_LOGO_PATH: Path = current_dir.parent / "img" / "fe-logo-rounded.png"
ICON_PATH: Path = current_dir.parent / "img" / "snowstorm.png"

# Change this to your fcapssh file path
SSH_KEY_PATH = "YOUR_SSH_KEY_PATH"


def handle_azure_errors(e) -> None:
    if "ResourceGroupNotFound" in e.stderr:
        print(f"Resource Group {RESOURCE_GROUP_NAME} not found!")
    if "ResourceNotFound" in e.stderr:
        print(f"Resource {VIRTUAL_MACHINE_SCALE_SETS_NAME} not found!")


def stop_vmss() -> None:
    command: str = (f"az vmss deallocate -g {RESOURCE_GROUP_NAME} -n {VIRTUAL_MACHINE_SCALE_SETS_NAME} --verbose")
    try:
        subprocess.run(["powershell", "-Command", command], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        handle_azure_errors(e)
        
def stop_vm() -> None:
    command: str = (f"az vm deallocate -g {RESOURCE_GROUP_NAME} -n {VIRTUAL_MACHINE_NAME} --verbose")
    try:
        subprocess.run(["powershell", "-Command", command], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        handle_azure_errors(e)


def start_resources() -> None:
    command: str = (
        f"az vmss start -g {RESOURCE_GROUP_NAME} -n {VIRTUAL_MACHINE_SCALE_SETS_NAME} ; "
        f"az vm start -g {RESOURCE_GROUP_NAME} -n {VIRTUAL_MACHINE_NAME} --verbose"
    )
    try:
        subprocess.run(["powershell", "-Command", command], capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as e:
        handle_azure_errors(e)
        
def vmss_process_gust_instant() -> None:
    vm_ip: str = open(VM_IP_PATH, "r").read().strip()
    command: str = f"ssh -i {SSH_KEY_PATH} azureadmin@{vm_ip} 'bash -s < ~/fewxops/software/vmss_process_gust_instant.sh'"
    try:
        subprocess.run(["powershell", "-Command", command])
    except FileNotFoundError:
        print("vm_ip.txt file not found!")
        
def jumpbox_process_gust_window() -> None:
    vm_ip: str = open(VM_IP_PATH, "r").read().strip()
    command: str = f"ssh -i {SSH_KEY_PATH} azureadmin@{vm_ip} 'bash -s < ~/fewxops/software/jumpbox_process_gust_window.sh'"
    try:
        subprocess.run(["powershell", "-Command", command])
    except FileNotFoundError:
        print("vm_ip.txt file not found!")


def main() -> None:
    # Create the main window
    root = Tk()
    root.geometry("430x295")
    root.title("FEWX 24 Hours GFS Processor")
    ico: ImageFile = Image.open(ICON_PATH)
    root.wm_iconphoto(False, ImageTk.PhotoImage(ico))

    # Set theme to dark
    sv_ttk.set_theme("dark")

    # Define style for button
    style = ttk.Style()
    style.configure("Process.TButton", foreground="white", background="white", font=("Geo Sans Light", 15, "bold"))

    # Define functions for command
    def get_cycle() -> str:
        cycle = combo_cycle.get()
        return cycle

    def get_date():
        date = cal.get_date().strftime("%Y%m%d")
        return date
    
    def update_progress(value):
        progress_bar["value"] = value
        root.update()

    def whole_processing() -> None:
        update_progress(0)
        start_resources()
        update_progress(15)
        subprocess.Popen(["python", "write_parameters.py", get_cycle(), get_date()])
        update_progress(30)
        vmss_process_gust_instant()
        update_progress(45)
        stop_vmss()
        update_progress(60)
        jumpbox_process_gust_window()
        update_progress(75)
        stop_vm()
        messagebox.showinfo("Done", "Process completed!")
        update_progress(100)
        
    # Create FE logo widget
    FE_frame = Frame(root)
    FE_frame.pack(pady=10)
    image: ImageFile = Image.open(FE_LOGO_PATH)
    smaller_image: Image.Image = image.resize((380, 100), Image.LANCZOS)
    photo = ImageTk.PhotoImage(smaller_image)
    label = Label(FE_frame, image=photo)
    label.pack()

    # Create parameters input widget
    cycle_frame = Frame(root)
    cycle_frame.place(x=48, y=140)
    combo_cycle = ttk.Combobox(cycle_frame, width=11, height=40, values=["0", "6", "12", "18"])
    combo_cycle.pack()
    combo_cycle.set("Select Cycle")

    date_frame = Frame(root)
    date_frame.place(x=243, y=140)
    cal = DateEntry(date_frame, width=11, height=40, background="black", foreground="white", borderwidth=2)
    cal.delete(0, "end")
    cal.insert(END, "Pick Date")
    cal.pack()

    # Create button widget
    button = ttk.Button(
        root, text="Generate Gust Window", command=whole_processing, width=28, style="Process.TButton"
    )
    button.place(x=48, y=200)
    
    s = ttk.Style()
    s.configure("white.Horizontal.TProgressbar", troughcolor ='white', background='white')
    progress_bar = ttk.Progressbar(root, style="white.Horizontal.TProgressbar", length=330, mode="determinate", orient="horizontal")
    progress_bar.pack(ipady=10, pady=(130,20))

    # Execute tkinter
    root.mainloop()


if __name__ == "__main__":
    main()