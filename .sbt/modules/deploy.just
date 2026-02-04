# ============================================================================
# Deployment recipes
# ============================================================================

# Deploy to a target environment
to env="staging":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Deploying {{project_name}}:{{image_tag}} → {{env}}"
  case "{{env}}" in
    staging)
      echo "  Target: staging cluster"
      # kubectl set image deployment/{{project_name}} \
      #   app={{registry}}/{{project_name}}:{{image_tag}} \
      #   -n staging
      echo "  (dry-run — uncomment kubectl commands to enable)"
      ;;
    production)
      echo "  ⚠ Production deployment"
      echo "  Target: production cluster"
      # kubectl set image deployment/{{project_name}} \
      #   app={{registry}}/{{project_name}}:{{image_tag}} \
      #   -n production
      echo "  (dry-run — uncomment kubectl commands to enable)"
      ;;
    *)
      echo "  ✗ Unknown environment: {{env}}"
      exit 1
      ;;
  esac
  echo "✓ Deployment to {{env}} complete"

# Show current deployment status
status env="staging":
  @echo "Deployment status for {{project_name}} in {{env}}:"
  @echo "  (configure with your actual kubectl/deployment commands)"
  # kubectl get pods -n {{env}} -l app={{project_name}}

# Rollback the last deployment
rollback env="staging":
  @echo "Rolling back {{project_name}} in {{env}}..."
  # kubectl rollout undo deployment/{{project_name}} -n {{env}}
  @echo "  (dry-run — uncomment kubectl commands to enable)"
