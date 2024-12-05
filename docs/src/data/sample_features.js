const features = {
  "Authentication": {
    "assignments": {
      "files": [
        "src/auth/controllers/login_controller.rb",
        "src/auth/services/oauth_service.rb",
        "src/auth/jobs/token_cleanup_job.rb",
        "src/auth/models/user.rb",
        "src/auth/middleware/auth_middleware.rb"
      ],
      "teams": ["Identity & Access"]
    },
    "description": "Core authentication system handling user login, OAuth integration, and session management",
    "documentation_link": "https://internal-docs.company.com/auth/overview",
    "metrics": {
      "abc_size": 245.32,
      "lines_of_code": 428,
      "cyclomatic_complexity": 36
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
      "abc_size": 892.45,
      "lines_of_code": 1247,
      "cyclomatic_complexity": 94
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
      "abc_size": 346.78,
      "lines_of_code": 582,
      "cyclomatic_complexity": 45
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
    }
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
      "abc_size": 289.34,
      "lines_of_code": 456,
      "cyclomatic_complexity": 34
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
      "teams": ["Search & Discovery", "Platform"]
    },
    "description": "Elasticsearch-based full-text search engine",
    "documentation_link": "https://internal-docs.company.com/search/overview",
    "metrics": {
      "abc_size": 645.78,
      "lines_of_code": 934,
      "cyclomatic_complexity": 76
    }
  }
 };

 export default features;
