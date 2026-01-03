# Contributing to AWS Infrastructure Project

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/Private-server-tf.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly
6. Commit and push
7. Open a Pull Request

## Development Workflow

### Before Making Changes

1. **Review existing documentation** in README.md and INFRASTRUCTURE.md
2. **Test in a dev environment** before proposing changes to production configs
3. **Ensure AWS credentials are configured** but never commit them

### Making Changes

#### Terraform Changes

```bash
# Format your code
terraform fmt -recursive

# Validate syntax
terraform validate

# Test your changes
terraform plan
```

#### Ansible Changes

```bash
# Check syntax
ansible-playbook playbook.yml --syntax-check

# Run in check mode first
ansible-playbook -i inventory.ini playbook.yml --check
```

### Code Style

#### Terraform

- Use consistent naming: `${var.project_name}-${resource_type}`
- Add comments for complex logic
- Use variables for configurable values
- Follow [Terraform best practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- Keep modules focused and reusable

#### Ansible

- Use descriptive task names
- Add comments for non-obvious tasks
- Use variables from vars.yml
- Test playbooks in dev environment first

## Submitting Changes

### Pull Request Guidelines

1. **Clear title and description**
   - Explain what changes were made and why
   - Reference any related issues

2. **Test your changes**
   - Run `terraform plan` successfully
   - Verify Ansible playbooks execute without errors
   - Document any manual testing performed

3. **Update documentation**
   - Update README.md if user-facing features change
   - Update INFRASTRUCTURE.md for technical changes
   - Update ansible/README.md for Ansible changes

4. **Keep commits atomic**
   - One logical change per commit
   - Write clear commit messages

### Commit Message Format

```
type: Brief description (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain the problem this commit solves and why this approach
was chosen.

Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## What to Contribute

### High Priority

- Security improvements
- Cost optimization
- Documentation improvements
- Bug fixes
- Performance enhancements

### Ideas for Contributions

- Implement SSL/TLS with ACM
- Add CloudWatch alarms and monitoring
- Implement backup solutions
- Add CI/CD pipeline examples
- Create additional modules (RDS, S3, etc.)
- Improve error handling in Ansible playbooks
- Add testing framework (Terratest, etc.)

## Testing Guidelines

### Infrastructure Testing

1. **Test in isolated environment**
   - Use separate AWS account or region
   - Use unique project_name to avoid conflicts

2. **Verify all outputs**
   ```bash
   terraform output
   ```

3. **Test connectivity**
   - SSH to bastion
   - SSH from bastion to app server
   - Access application via ALB

### Ansible Testing

1. **Syntax check**
   ```bash
   ansible-playbook playbook.yml --syntax-check
   ```

2. **Dry run**
   ```bash
   ansible-playbook -i inventory.ini playbook.yml --check
   ```

3. **Verify deployment**
   - Check Docker containers are running
   - Verify application responds
   - Check logs for errors

## Security Considerations

### Never Commit

- AWS credentials or access keys
- Private SSH keys
- terraform.tfstate files (contain sensitive data)
- .tfvars files with real values
- Passwords or API tokens

### Always

- Use IAM roles when possible
- Follow principle of least privilege
- Review security group rules
- Use separate environments (dev/staging/prod)
- Encrypt sensitive data

## Documentation Standards

### Code Comments

- Explain **why**, not what
- Document complex logic
- Add module descriptions
- Document variables and outputs

### README Updates

Update if you change:
- Setup/installation steps
- Configuration requirements
- Architecture
- Prerequisites

### Example Documentation

```hcl
# =========================================================================
# RESOURCE DESCRIPTION
# =========================================================================
# This resource does X because Y. It's configured this way to achieve Z.

resource "aws_example" "main" {
  # Clear explanation for non-obvious settings
  setting = "value"  # Why this specific value
}
```

## Questions or Issues?

- **Questions:** Open a GitHub Discussion
- **Bugs:** Open an Issue with:
  - Clear description
  - Steps to reproduce
  - Expected vs actual behavior
  - Environment details (Terraform version, AWS region, etc.)
- **Feature requests:** Open an Issue with:
  - Use case description
  - Proposed solution
  - Alternatives considered

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the issue, not the person
- Assume good intentions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing! 🚀
