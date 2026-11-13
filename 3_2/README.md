# 3.2 Deployment pipeline to a cloud service

Deployed app: https://devops-docker-backend.onrender.com/ping

Pipeline: .github/workflows/deploy-render.yml

On every push to main that changes example-app/backend or the workflow itself,
GitHub Actions builds example-app/backend, pushes laomaiai/example-backend:latest
to Docker Hub, then triggers the Render deploy hook
(secret RENDER_DEPLOY_HOOK_URL) so Render redeploys the service.

Secrets used: DOCKERHUB_USERNAME, DOCKERHUB_TOKEN, RENDER_DEPLOY_HOOK_URL.
Verify after a push: the Render dashboard shows a new deploy, and
GET https://devops-docker-backend.onrender.com/ping returns pong.
