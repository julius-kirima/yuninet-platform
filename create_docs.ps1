
## Reporting Issues

- Use GitHub Issues to report bugs or suggest features.

## Code of Conduct

Please respect the [Code of Conduct](CODE_OF_CONDUCT.md).

"@ | Out-File -Encoding UTF8 docs\Contribution_Guide.md

@"
# FAQ

## How do I verify my student identity?

Use your official admission number or student ID during registration and login.

## What if I forget my password?

Use the password recovery option in the app or contact support.

## Can I contribute to the project?

Yes! Check the Contribution Guide for details.

## How do I report bugs or suggest features?

Open an issue on GitHub in the Issues tab.

## Where can I find the roadmap?

See the [Roadmap](ROADMAP.md) document.

"@ | Out-File -Encoding UTF8 docs\FAQ.md

@"
# Roadmap

## Upcoming Features

- Integration with school administrative systems
- Enhanced real-time notifications
- Advanced digital skills training modules
- More social interaction features (groups, events)
- Mobile push notifications
- Multi-language support

## Long-term Goals

- Expand platform to multiple institutions
- Monetization options for content creators
- AI-driven academic assistance

## How to Influence the Roadmap

Community feedback is welcome! Please open issues or PRs with your ideas.

"@ | Out-File -Encoding UTF8 docs\ROADMAP.md

Write-Host "All documentation files created successfully in the docs/ folder.`n"
Write-Host "Run the following commands to commit and push:"
Write-Host "git add docs"
Write-Host "git commit -m `"Add full documentation with detailed content`""
Write-Host "git push origin main"
'@ | Out-File -Encoding UTF8 create_docs.ps1
