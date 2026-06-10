# Contributing to NexAPI

Thank you for your interest in contributing to NexAPI! This project is designed for educational security research, and contributions are welcome.

## How to Contribute

### Reporting Issues

When reporting issues, please include:
- Clear description of the problem
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Environment details (OS, Ruby version, Rails version)
- Relevant error messages or logs

### Suggesting Enhancements

Enhancement suggestions should:
- Clearly describe the proposed feature or improvement
- Explain the use case and benefits
- Provide examples if applicable
- Consider alignment with the project's educational goals

### Adding New Vulnerability Exploits

If you want to add new vulnerability exploit documentation:

1. **Follow the naming convention**: `API[Number]_[Vulnerability_Name].md`
2. **Use the template structure** from existing exploit files
3. **Include all sections**:
   - Description
   - Severity level
   - OWASP reference
   - Affected endpoints
   - Steps to reproduce
   - Vulnerable code example
   - Impact assessment
   - Remediation guidance
4. **Test thoroughly**: Ensure all steps work as documented
5. **Update README**: Add the new exploit to the vulnerability index

### Code Contributions

For code changes to the vulnerable application:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test thoroughly**: Ensure the application still runs and vulnerabilities remain intentional
5. **Submit a pull request** with clear description

### Documentation Improvements

Documentation contributions are highly valued:
- Fix typos or grammatical errors
- Improve clarity of existing explanations
- Add diagrams or visual aids
- Translate documentation to other languages
- Add troubleshooting guides

## Development Guidelines

### Code Style

- Follow Ruby on Rails conventions
- Use meaningful variable and function names
- Add comments for intentionally vulnerable code
- Keep the vulnerable code clearly marked with vulnerability IDs

### Commit Messages

Use clear, descriptive commit messages:
```
feat: add SSRF vulnerability webhook endpoint
docs: update installation instructions for Ubuntu 22.04
fix: correct JWT secret in auth controller
```

### Testing

- Test all changes in a clean environment
- Verify the setup script works
- Ensure documented exploits still function
- Check that the application starts without errors

## Project Structure

```
NexAPI/
├── app/                    # Rails application code
│   └── controllers/        # Vulnerable controllers
├── exploits/              # Vulnerability exploit documentation
│   ├── API1_Broken_Object_Level_Authorization.md
│   ├── API2_Broken_Authentication.md
│   └── ...
├── setup/                 # Installation and setup scripts
│   └── install.sh
├── README.md              # Main project documentation
├── LICENSE                # MIT License
├── SECURITY.md            # Security policy and disclaimer
└── CONTRIBUTING.md        # This file
```

## Educational Focus

Remember that NexAPI is primarily an educational tool. Contributions should:
- Enhance the learning experience
- Provide clear, actionable guidance
- Maintain the focus on OWASP API Security Top 10
- Support ethical security research practices

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers and help them learn
- Focus on what is best for the community
- Show empathy towards other community members

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue for questions or discussion about potential contributions.
