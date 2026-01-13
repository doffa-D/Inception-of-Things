Step 1: Read Vagrantfile
#↑ "Let me see what you want me to build..."

Step 2: Check if Ubuntu box exists
#↑ "Do I have 'bento/ubuntu-22.04' downloaded?"
#If NO → Download it from the internet (takes 2-5 minutes)
#   If YES → Use the cached version

Step 3: Build Server VM
#↑ "Creating HdagdaguServer..."
    → VirtualBox creates a new virtual machine
    → Allocates 1 CPU and 1024MB RAM
    → Installs Ubuntu 22.04
    → Sets hostname to "HdagdaguServer"
    → Creates network card with IP 192.168.56.110
    → Starts the machine

Step 4: Build Worker VM
#↑ "Creating HdagdaguWorker..."
    → VirtualBox creates a second virtual machine
    → Allocates 1 CPU and 1024MB RAM
    → Installs Ubuntu 22.04
    → Sets hostname to "HdagdaguWorker"
    → Creates network card with IP 192.168.56.111
    → Starts the machine

Step 5: Configure SSH
#↑ "Setting up passwordless SSH access..."
    → Generates SSH keys
    → Configures both machines for easy access

Step 6: Mount shared folders
#↑ "Sharing your p1/ folder with the VMs..."
    → Your p1/ folder is accessible inside VMs at /vagrant

Step 7: Done!
#↑ "Both machines are running and ready!"