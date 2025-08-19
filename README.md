# Mini Linux System Management Tool

A comprehensive, modular bash-based system administration tool designed to provide essential Linux system management capabilities through an intuitive menu-driven interface.

## Overview

The Mini Linux System Management Tool is a collection of bash scripts organized in a modular architecture that enables system administrators and users to perform common Linux system management tasks without memorizing complex command-line syntax.

## Features

### System Management
- **System Status**: Real-time CPU, RAM, disk usage, and system information
- **Disk Management**: Disk space analysis, inode usage, and S.M.A.R.T. health monitoring
- **Performance Monitoring**: System resource utilization and performance metrics

### User Management
- **User Operations**: Add, modify, and manage system users and groups
- **User Information**: Comprehensive user listing with detailed information
- **Access Control**: User permission management and security settings

### Service Management
- **Service Status**: Monitor and manage system services (systemd/SysV init)
- **Service Control**: Start, stop, restart, and enable/disable services
- **Service Statistics**: Service performance and status reporting

### Package Management
- **Multi-Distribution Support**: Compatible with apt, dnf, yum, pacman, zypper, and emerge
- **Package Installation**: Install packages with dependency resolution
- **Package Search**: Find and install packages from repositories

### Network Management
- **Network Status**: Interface information, IP addresses, and network configuration
- **Network Diagnostics**: Port scanning, connectivity testing, and traffic analysis
- **Network Tools**: Advanced network troubleshooting utilities

### File System Management
- **File Explorer**: Interactive file system navigation and management
- **File Operations**: Copy, move, delete, and modify files and directories
- **Permission Management**: File and directory permission control

### Backup and Recovery
- **Backup Creation**: Directory, configuration, and full system backups
- **Backup Restoration**: Restore backups with validation and safety checks
- **Backup Management**: Backup scheduling, cleanup, and monitoring

### Log Management
- **System Logs**: View and analyze system logs from journalctl and /var/log
- **Log Monitoring**: Real-time log monitoring and filtering
- **Log Maintenance**: Log rotation and cleanup utilities

### Configuration Management
- **Tool Configuration**: Centralized configuration management
- **Theme System**: Customizable user interface themes
- **Settings Management**: Persistent configuration storage

## Architecture

### Modular Design
The tool follows a modular architecture where each functionality is implemented as a separate script:

```
mini-linux-sysmng/
├── mini-sysmgmt.sh          # Main application entry point
├── modules/                  # Functional modules
│   ├── system/              # System management modules
│   ├── users/               # User management modules
│   ├── services/            # Service management modules
│   ├── packages/            # Package management modules
│   ├── network/             # Network management modules
│   ├── files/               # File system modules
│   ├── logs/                # Log management modules
│   ├── backup/              # Backup and recovery modules
│   └── tools/               # Utility and configuration modules
├── themes/                   # User interface themes
├── config/                   # Configuration files
├── scripts/                  # Installation and maintenance scripts
└── docs/                     # Documentation
```

### Theme System
The tool includes a comprehensive theming system that provides:
- Consistent color schemes across all modules
- Customizable user interface elements
- Professional appearance and readability

## Requirements

### System Requirements
- **Operating System**: Linux (Ubuntu, Debian, CentOS, RHEL, Fedora, Arch Linux, openSUSE, Gentoo)
- **Shell**: Bash 4.0 or higher
- **Architecture**: x86_64, ARM64, or compatible

### Dependencies
- **Core Utilities**: Standard GNU/Linux utilities (ls, find, grep, awk, sed)
- **System Tools**: htop, tree, curl, wget (installed automatically)
- **Network Tools**: net-tools, iproute2
- **Package Managers**: Distribution-specific package managers

## Installation

### Quick Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/mini-linux-sysmng.git
cd mini-linux-sysmng

# Run the installation script
sudo ./scripts/install.sh

# Start the tool
./mini-sysmgmt.sh
```

### Manual Installation
```bash
# Make scripts executable
chmod +x mini-sysmgmt.sh
chmod +x scripts/*.sh
chmod +x modules/*/*.sh

# Install dependencies manually
sudo apt update
sudo apt install htop tree curl wget git net-tools
```

## Usage

### Starting the Tool
```bash
./mini-sysmgmt.sh
```

### Main Menu Navigation
The tool provides a comprehensive menu system with 35 options organized into logical categories:

1. **System Management** (Options 1-5)
2. **User Management** (Options 6-9)
3. **Service Management** (Options 10-13)
4. **Package Management** (Options 14-17)
5. **Network Management** (Options 18-21)
6. **File Management** (Options 22-25)
7. **Log Management** (Options 26-29)
8. **Backup Management** (Options 30-32)
9. **Tool Configuration** (Options 33-35)

### Module Usage
Each module provides its own submenu and functionality. Users can navigate through options using numeric input and return to the main menu at any time.

## Configuration

### Configuration Files
- **`config/sysmgmt.conf`**: Main configuration file
- **`config/themes.conf`**: Theme configuration
- **`config/shortcuts.conf`**: Quick access shortcuts

### Customization
The tool can be customized through:
- Configuration file modifications
- Theme customization
- Module addition and modification

## Security

### Root Privileges
Certain operations require root privileges for security reasons:
- User management operations
- Service management
- System configuration changes
- Backup and restoration operations

### Safety Features
- Confirmation prompts for destructive operations
- Input validation and sanitization
- Error handling and logging
- Backup verification

## Development

### Adding New Modules
To add new functionality:

1. Create a new script in the appropriate module directory
2. Implement the required functions
3. Include the theme system for consistent appearance
4. Add menu integration in the main script
5. Test thoroughly before deployment

### Module Structure
Each module should:
- Source the theme file for consistent appearance
- Include proper error handling
- Provide clear user feedback
- Follow the established naming conventions

### Testing
- Test modules individually
- Verify integration with the main system
- Check error handling and edge cases
- Validate user experience and interface consistency

## Troubleshooting

### Common Issues
- **Permission Denied**: Ensure scripts have execute permissions
- **Module Not Found**: Check module file paths and permissions
- **Theme Errors**: Verify theme file existence and syntax
- **Dependency Issues**: Install required system packages

### Debug Mode
Enable debug output by setting the DEBUG environment variable:
```bash
DEBUG=1 ./mini-sysmgmt.sh
```

### Log Files
Check system logs for detailed error information:
```bash
journalctl -u your-service
tail -f /var/log/syslog
```

## Contributing

### Development Guidelines
- Follow bash scripting best practices
- Maintain consistent code style
- Include comprehensive error handling
- Document all functions and features
- Test thoroughly on multiple distributions

### Code Review Process
1. Submit pull requests with detailed descriptions
2. Ensure all tests pass
3. Follow the established coding standards
4. Include appropriate documentation updates

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

### Documentation
- Comprehensive inline documentation
- Module-specific help systems
- Configuration examples
- Troubleshooting guides

### Community
- GitHub Issues for bug reports
- Discussion forums for questions
- Wiki for additional documentation
- Contributing guidelines for developers

## Version History

### Current Version: 1.0.0
- Initial release with core functionality
- Modular architecture implementation
- Theme system integration
- Multi-distribution package management support

### Planned Features
- Web-based interface
- API integration capabilities
- Advanced monitoring and alerting
- Cloud deployment support
- Container management integration

## Acknowledgments

- Linux community for inspiration and best practices
- Bash scripting community for technical guidance
- Open source contributors for continuous improvement
- System administrators for feature requests and feedback

---

**Note**: This tool is designed for educational and professional use. Always test in a safe environment before using in production systems.
