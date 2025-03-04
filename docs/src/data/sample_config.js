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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 35.5, "percent_of_max": 80, "score": 12 },
        "encapsulation": { "percentile": 65.2, "percent_of_max": 75, "score": 10 },
        "feature_size": { "percentile": 46.3, "percent_of_max": 13, "score": 1500 },
        "test_coverage": { "percentile": 88.4, "percent_of_max": 95, "score": 85 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 66.5,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 12.0,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 11.25,
            "close_to_maximum_score": true
          },
          "overall": 89.75
        }
      },
      "test_coverage": {
        "lines": 1200,
        "hits": 1140,
        "misses": 60
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 78.2, "percent_of_max": 65, "score": 14 },
        "encapsulation": { "percentile": 92.1, "percent_of_max": 88, "score": 13 },
        "feature_size": { "percentile": 82.5, "percent_of_max": 45, "score": 2500 },
        "test_coverage": { "percentile": 95.8, "percent_of_max": 98, "score": 90 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 68.6,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 13.2,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 13.8,
            "close_to_maximum_score": true
          },
          "overall": 95.6
        }
      },
      "test_coverage": {
        "lines": 2582,
        "hits": 2530,
        "misses": 52
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 45.6, "percent_of_max": 42, "score": 10 },
        "encapsulation": { "percentile": 58.3, "percent_of_max": 55, "score": 9 },
        "feature_size": { "percentile": 63.2, "percent_of_max": 28, "score": 1800 },
        "test_coverage": { "percentile": 70.1, "percent_of_max": 70, "score": 75 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 49.0,
            "close_to_maximum_score": false
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 8.25,
            "close_to_maximum_score": false
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 8.25,
            "close_to_maximum_score": false
          },
          "overall": 65.5
        }
      },
      "test_coverage": {
        "lines": 1582,
        "hits": 1108,
        "misses": 474
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 92.3, "percent_of_max": 95, "score": 15 },
        "encapsulation": { "percentile": 88.7, "percent_of_max": 85, "score": 14 },
        "feature_size": { "percentile": 25.4, "percent_of_max": 8, "score": 500 },
        "test_coverage": { "percentile": 98.9, "percent_of_max": 99, "score": 95 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 69.3,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 14.25,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 13.5,
            "close_to_maximum_score": true
          },
          "overall": 97.05
        }
      },
      "test_coverage": {
        "lines": 289,
        "hits": 286,
        "misses": 3
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
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
      "test_coverage": null,
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 68.4, "percent_of_max": 72, "score": 13 },
        "encapsulation": { "percentile": 75.6, "percent_of_max": 70, "score": 12 },
        "feature_size": { "percentile": 55.8, "percent_of_max": 35, "score": 2000 },
        "test_coverage": { "percentile": 82.3, "percent_of_max": 85, "score": 80 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 59.5,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 10.8,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 10.5,
            "close_to_maximum_score": true
          },
          "overall": 80.8
        }
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
      },
      "test_coverage": {
        "lines": 412,
        "hits": 324,
        "misses": 88
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
      },
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 85.2, "percent_of_max": 82, "score": 14 },
        "encapsulation": { "percentile": 78.9, "percent_of_max": 75, "score": 13 },
        "feature_size": { "percentile": 42.1, "percent_of_max": 25, "score": 1200 },
        "test_coverage": { "percentile": 78.6, "percent_of_max": 80, "score": 70 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 55.0,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 12.3,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 11.25,
            "close_to_maximum_score": true
          },
          "overall": 78.55
        }
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
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
      },
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 89.5, "percent_of_max": 88, "score": 15 },
        "encapsulation": { "percentile": 92.3, "percent_of_max": 90, "score": 14 },
        "feature_size": { "percentile": 58.7, "percent_of_max": 42, "score": 2200 },
        "test_coverage": { "percentile": 98.2, "percent_of_max": 99, "score": 90 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 68.6,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 13.5,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 13.8,
            "close_to_maximum_score": true
          },
          "overall": 95.9
        }
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
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
      },
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 72.4, "percent_of_max": 68, "score": 12 },
        "encapsulation": { "percentile": 65.8, "percent_of_max": 62, "score": 11 },
        "feature_size": { "percentile": 68.9, "percent_of_max": 55, "score": 2500 },
        "test_coverage": { "percentile": 59.8, "percent_of_max": 60, "score": 60 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 42.0,
            "close_to_maximum_score": false
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 10.2,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 9.3,
            "close_to_maximum_score": false
          },
          "overall": 61.5
        }
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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 62.8, "percent_of_max": 58, "score": 11 },
        "encapsulation": { "percentile": 71.2, "percent_of_max": 65, "score": 10 },
        "feature_size": { "percentile": 82.4, "percent_of_max": 75, "score": 2700 },
        "test_coverage": { "percentile": 68.5, "percent_of_max": 70, "score": 65 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 49.0,
            "close_to_maximum_score": false
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 8.7,
            "close_to_maximum_score": false
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 9.75,
            "close_to_maximum_score": false
          },
          "overall": 67.45
        }
      },
      "test_coverage": {
        "lines": 1456,
        "hits": 998,
        "misses": 458
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
      },
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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 75.0, "percent_of_max": 70, "score": 13 },
        "encapsulation": { "percentile": 80.0, "percent_of_max": 75, "score": 12 },
        "feature_size": { "percentile": 60.0, "percent_of_max": 50, "score": 1800 },
        "test_coverage": { "percentile": 85.0, "percent_of_max": 80, "score": 75 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 68.0,
            "close_to_maximum_score": true
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 10.5,
            "close_to_maximum_score": true
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 11.25,
            "close_to_maximum_score": true
          },
          "overall": 89.75
        }
      },
      "test_coverage": {
        "lines": 567,
        "hits": 489,
        "misses": 78
      },
      "test_pyramid": {
        "unit_count": 100,
        "unit_pending": 5,
        "integration_count": 20,
        "integration_pending": 2,
        "regression_count": 5,
        "regression_pending": 1
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
      "additional_metrics": {
        "cyclomatic_complexity": { "percentile": 0.0, "percent_of_max": 0, "score": 0 },
        "encapsulation": { "percentile": 0.0, "percent_of_max": 0, "score": 0 },
        "feature_size": { "percentile": 0.0, "percent_of_max": 0, "score": 0 },
        "test_coverage": { "percentile": 0.0, "percent_of_max": 0, "score": 0 },
        "health": {
          "test_coverage_component": {
            "awardable_points": 70, "health_score": 0.0,
            "close_to_maximum_score": false
          },
          "cyclomatic_complexity_component": {
            "awardable_points": 15, "health_score": 0.0,
            "close_to_maximum_score": false
          },
          "encapsulation_component": {
            "awardable_points": 15, "health_score": 0.0,
            "close_to_maximum_score": false
          },
          "overall": 0.0
        }
      },
      "test_coverage": null
    },
  },
};

export default config;
