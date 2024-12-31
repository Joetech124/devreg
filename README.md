# DevReg - Advanced Device Registration and Management System

DevReg is a sophisticated blockchain-based application built on the Stacks ecosystem using Clarity. It allows users to register, manage, and transfer ownership of electronic devices with enhanced security features and metadata management.

## Features

- Register devices with unique IDs, names, and descriptions
- Prevent duplicate registrations
- Transfer device ownership with a transfer limit
- Update device metadata
- Track device registration time and transfer count
- Efficient user device count management

## How It Works

1. Users register a device with a unique ID, name, and description
2. The app stores this data on the blockchain, including registration time
3. Device IDs are validated to ensure uniqueness
4. Users can transfer device ownership, subject to a transfer limit
5. Device metadata can be updated by the current owner
6. The system tracks the number of devices owned by each user

## Why DevReg?

DevReg is designed to be a comprehensive solution for device registration and management on the blockchain. It's suitable for various use cases, from personal device tracking to enterprise-level asset management.

## Tools and Requirements

- **Stacks Blockchain**: The platform powering DevReg
- **Clarity**: The smart contract language used
- **Clarinet**: Development tool for testing and deploying Clarity smart contracts

## Smart Contract Functions

- `register-device`: Register a new device with metadata
- `is-device-registered`: Check if a device is registered
- `get-device-owner`: Get the owner of a registered device
- `get-device-metadata`: Retrieve device metadata
- `transfer-device`: Transfer device ownership (with transfer limit)
- `update-device-metadata`: Update device name and description
- `get-user-device-count`: Get the number of devices registered by a user
- `user-has-devices`: Check if a user owns any devices

## Security Features

- Transfer limit to prevent excessive ownership changes
- Owner-only actions for transfers and metadata updates
- Input validation to ensure data integrity

## Next Steps

- Implement a user interface for interacting with the smart contract
- Develop a comprehensive test suite using Clarinet
- Explore integration with other Stacks ecosystem projects