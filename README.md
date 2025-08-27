# Calender

A modern Rails application built with the latest web technologies.

## Features

- **Rails 8.0.2** - Latest Rails framework
- **MySQL** - Robust database backend
- **Tailwind CSS** - Utility-first CSS framework
- **Hotwire (Turbo + Stimulus)** - Modern JavaScript approach
- **Import Maps** - Native ES modules without bundling
- **Docker Support** - Containerized deployment with Kamal

## Prerequisites

- Ruby 3.4.2
- MySQL 5.7 or higher
- Node.js 18+ (for Tailwind CSS compilation)
- Docker (optional, for containerized deployment)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd calender
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Install Node.js dependencies**
   ```bash
   npm install
   ```

4. **Configure database**
   ```bash
   cp config/database.yml.example config/database.yml
   # Edit config/database.yml with your database credentials
   ```

5. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

6. **Compile assets**
   ```bash
   rails assets:precompile
   ```

## Development

### Starting the server
```bash
# Start Rails server
rails server

# Start Tailwind CSS watcher (in another terminal)
rails tailwindcss:watch
```

### Running tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code quality
```bash
# Run RuboCop
bundle exec rubocop

# Auto-correct RuboCop violations
bundle exec rubocop -a

# Run Brakeman security scanner
bundle exec brakeman
```

## Deployment

This application uses [Kamal](https://kamal-deploy.org/) for deployment.

```bash
# Deploy to production
kamal deploy

# Deploy to staging
kamal deploy --config config/deploy.staging.yml
```

## Project Structure

```
calender/
├── app/                    # Application code
│   ├── controllers/       # Controllers
│   ├── models/           # Models
│   ├── views/            # Views
│   ├── assets/           # Asset pipeline
│   └── javascript/       # JavaScript files
├── config/               # Configuration files
├── db/                   # Database files
├── docs/                 # Documentation
├── test/                 # Test files
└── public/               # Public assets
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions, please open an issue in the GitHub repository.
