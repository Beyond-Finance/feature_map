// This file contains fake/generic data to obfuscates company and/or product specific feature data from the gem itself.
// Also, this is meant to make local development easier.
const config = {
  environment: {
    GITHUB_SHA_URL: 'https://example.com/blob/abcd'
  },
  features: {
    "Authentication": {
      "assignments": {
        "files": ["src/auth/controllers/login_controller.rb", "src/auth/services/oauth_service.rb", "src/auth/jobs/token_cleanup_job.rb", "src/auth/models/user.rb", "src/auth/middleware/auth_middleware.rb"],
        "teams": ["Identity & Access"]
      },
      "description": "Core authentication system handling user login, OAuth integration, and session management",
      "documentation_link": "https://internal-docs.company.com/auth/overview",
      "metrics": {
        "abc_size": 890.8100000000001,
        "lines_of_code": 1200,
        "cyclomatic_complexity": 400,
        "todo_locations": {
          "src/auth/services/oauth_service.rb:124": "Refactor this method",
          "src/auth/middleware/auth_middleware.rb:45": "Add documentation for this class"
        }
      },
      "test_coverage": {
        "lines": 1200,
        "hits": 1140,
        "misses": 60
      }
    },
    "Payment Processing": {
      "assignments": {
        "files": [
          "src/payments/controllers/charges_controller.rb",
          "src/payments/services/stripe_service.rb",
          "src/payments/jobs/payment_reconciliation_job.rb",
          "src/payments/models/payment.rb",
          "src/payments/models/refund.rb",
          "src/payments/workers/payment_worker.rb",
          "src/payments/validators/payment_validator.rb"
        ],
        "teams": ["Payments", "Revenue"]
      },
      "description": "Payment processing system integrating with Stripe for charges, refunds and reconciliation",
      "documentation_link": "https://internal-docs.company.com/payments/overview",
      "metrics": {
        "abc_size": 502.78,
        "lines_of_code": 5582,
        "cyclomatic_complexity": 500
      },
      "test_coverage": {
        "lines": 2582,
        "hits": 2530,
        "misses": 52
      }
    },
    "User Management": {
      "assignments": {
        "files": [
          "src/users/controllers/users_controller.rb",
          "src/users/services/user_service.rb",
          "src/users/jobs/user_cleanup_job.rb",
          "src/users/models/profile.rb",
          "src/users/workers/profile_worker.rb"
        ],
        "teams": ["Identity & Access"]
      },
      "description": "User profile and account management system",
      "documentation_link": "https://internal-docs.company.com/users/overview",
      "metrics": {
        "abc_size": 1202.78,
        "lines_of_code": 1582,
        "cyclomatic_complexity": 300
      },
      "test_coverage": {
        "lines": 1582,
        "hits": 1108,
        "misses": 474
      }
    },
    "Email Service": {
      "assignments": {
        "files": [
          "src/email/services/email_service.rb",
          "src/email/jobs/email_sender_job.rb",
          "src/email/templates/welcome_email.rb",
          "src/email/templates/reset_password.rb"
        ],
        "teams": ["Communications"]
      },
      "description": "Transactional email service handling all system notifications",
      "documentation_link": "https://internal-docs.company.com/email/overview",
      "metrics": {
        "abc_size": 156.92,
        "lines_of_code": 289,
        "cyclomatic_complexity": 22
      },
      "test_coverage": {
        "lines": 289,
        "hits": 286,
        "misses": 3
      }
    },
    "Data Sync": {
      "assignments": {
        "files": [
          "src/sync/controllers/sync_controller.rb",
          "src/sync/services/sync_service.rb",
          "src/sync/jobs/sync_job.rb",
          "src/sync/models/sync_record.rb",
          "src/sync/workers/sync_worker.rb",
          "src/sync/validators/sync_validator.rb"
        ],
        "teams": ["Platform", "Data Infrastructure"]
      },
      "description": "Real-time data synchronization system between services",
      "documentation_link": "https://internal-docs.company.com/sync/overview",
      "metrics": {
        "abc_size": 764.23,
        "lines_of_code": 1124,
        "cyclomatic_complexity": 82
      },
      "test_coverage": null
    },
    "Analytics": {
      "assignments": {
        "files": [
          "src/analytics/services/tracking_service.rb",
          "src/analytics/jobs/event_processor_job.rb",
          "src/analytics/models/event.rb",
          "src/analytics/workers/analytics_worker.rb"
        ],
        "teams": ["Data Science"]
      },
      "description": "User behavior tracking and analytics processing pipeline",
      "documentation_link": "https://internal-docs.company.com/analytics/overview",
      "metrics": {
        "abc_size": 234.56,
        "lines_of_code": 412,
        "cyclomatic_complexity": 28
      },
      "test_coverage": {
        "lines": 412,
        "hits": 324,
        "misses": 88
      }
    },
    "API Gateway": {
      "assignments": {
        "files": [
          "src/gateway/controllers/api_controller.rb",
          "src/gateway/services/rate_limiter.rb",
          "src/gateway/middleware/api_middleware.rb",
          "src/gateway/models/api_key.rb"
        ],
        "teams": ["Platform"]
      },
      "description": "API Gateway handling authentication, rate limiting and request routing",
      "documentation_link": "https://internal-docs.company.com/gateway/overview",
      "metrics": {
        "abc_size": 423.67,
        "lines_of_code": 678,
        "cyclomatic_complexity": 52
      },
      "test_coverage": {
        "lines": 678,
        "hits": 671,
        "misses": 7
      }
    },
    "Document Processing": {
      "assignments": {
        "files": [
          "src/documents/services/document_service.rb",
          "src/documents/jobs/document_processor_job.rb",
          "src/documents/models/document.rb",
          "src/documents/workers/pdf_worker.rb",
          "src/documents/validators/document_validator.rb"
        ],
        "teams": ["Content Management"]
      },
      "description": "Document processing system for PDF generation and manipulation",
      "documentation_link": "https://internal-docs.company.com/documents/overview",
      "metrics": {
        "abc_size": 534.89,
        "lines_of_code": 892,
        "cyclomatic_complexity": 64
      },
      "test_coverage": {
        "lines": 892,
        "hits": 534,
        "misses": 358
      }
    },
    "Notification System": {
      "assignments": {
        "files": [
          "src/notifications/services/notification_service.rb",
          "src/notifications/jobs/notification_sender_job.rb",
          "src/notifications/models/notification.rb",
          "src/notifications/workers/push_notification_worker.rb"
        ],
        "teams": ["Communications"]
      },
      "description": "Push notification system for mobile and web clients",
      "documentation_link": "https://internal-docs.company.com/notifications/overview",
      "metrics": {
        "abc_size": 780.34,
        "lines_of_code": 1456,
        "cyclomatic_complexity": 241
      },
      "test_coverage": {
        "lines": 1456,
        "hits": 998,
        "misses": 458
      }
    },
    "Search Engine": {
      "assignments": {
        "files": [
          "src/search/controllers/search_controller.rb",
          "src/search/services/elasticsearch_service.rb",
          "src/search/jobs/index_job.rb",
          "src/search/models/search_index.rb",
          "src/search/workers/indexing_worker.rb"
        ],
        "teams": ["Search & Discovery", "Platform", "Communications", "Admin"]
      },
      "description": "Elasticsearch-based full-text search engine",
      "documentation_link": "https://internal-docs.company.com/search/overview",
      "metrics": {
        "abc_size": 645.78,
        "lines_of_code": 934,
        "cyclomatic_complexity": 76
      },
      "test_coverage": {
        "lines": 567,
        "hits": 489,
        "misses": 78
      }
    },
    "Cache Management": {
      "assignments": {
        "files": null,
        "teams": null
      },
      "description": null,
      "documentation_link": null,
      "metrics": {
        "abc_size": null,
        "lines_of_code": null,
        "cyclomatic_complexity": null
      },
      "test_coverage": null
    },
  },
};

export default config;
