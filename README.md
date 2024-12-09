
# Docker PHP Base Image

`docker-php-base-image` is a streamlined Docker base image for PHP 8.2 applications. It includes essential dependencies, optimized configurations, and automated CI/CD workflows for building, versioning, and deploying Docker images.

## Features

- Base image for PHP 8.2 applications with required dependencies and extensions.
- Semantic versioning based on commit messages.
- GitHub Actions workflows for automated image building and pushing to GitHub Container Registry (GHCR).
- Easy customization for project-specific needs.

## Folder Structure

- `php-8.2/`
  - Contains the Dockerfile for building the PHP base image.

- `.github/workflows/`
  - Contains the GitHub Actions workflow for CI/CD, including semantic versioning, Docker image build, and push.

## Usage

### 1. Build the Docker Image Locally

Navigate to the `php-8.2` folder and build the Docker image locally using:

```bash
docker build -t your-image-name:tag ./php-8.2
```

### 2. Push the Image to a Registry

To manually push the built image to a container registry:

```bash
docker tag your-image-name:tag ghcr.io/your-username/your-repo:tag
docker push ghcr.io/your-username/your-repo:tag
```

### 3. Automate with GitHub Actions

The included GitHub Actions workflow automates:

1. Semantic version tagging based on commit messages.
2. Docker image building and pushing to GHCR.

### 4. Commit Message Guidelines

- `bump: major` – For breaking changes.
- `bump: minor` – For new features.
- `bump: patch` – For bug fixes or minor updates.

### 5. Workflow Execution

The GitHub Actions workflow triggers on `push` events to the `main` branch and handles versioning, building, and pushing the Docker image.

## Contributing

Contributions are welcome! Feel free to open issues or pull requests to improve this project.

## License

This project is licensed under the MIT License.
