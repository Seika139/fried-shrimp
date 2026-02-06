# 1. 使用するプロバイダ（GitHub）の定義
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# 2. GitHubへの接続設定
# token と owner は環境変数 GITHUB_TOKEN, GITHUB_OWNER から自動的に読み込まれます
provider "github" {}

variable "github_repository_full_name" {
  type        = string
  description = "The full name of the GitHub repository (e.g., 'owner/repo')."
}

# 3. 既存のリポジトリを指定
import {
  to = github_repository.repo
  id = split("/", var.github_repository_full_name)[1]
}

resource "github_repository" "repo" {
  name                   = split("/", var.github_repository_full_name)[1]
  description            = "Your own personal AI assistant. Any OS. Any Platform. The lobster way. 🦞 "
  delete_branch_on_merge = true
  allow_update_branch    = true
  has_issues             = true
  has_projects           = true
  has_wiki               = true
  homepage_url           = "https://openclaw.ai"
  vulnerability_alerts   = true
}

# 4. リポジトリルールセットの設定
resource "github_repository_ruleset" "main" {
  name        = "main-protection"
  repository  = github_repository.repo.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    # ブランチの削除を禁止
    deletion = true

    # 強制プッシュを禁止（Non-fast-forward pushの禁止）
    non_fast_forward = true

    # マージにはプルリクエストを必須にする
    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = true
      required_review_thread_resolution = true
      require_code_owner_review         = false
      require_last_push_approval        = false
    }

    # ステータスチェック（ lint など）を必須にする
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context        = "markdownlint"
        integration_id = 15368
      }
    }
  }
}
