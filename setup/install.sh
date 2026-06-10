#!/bin/bash
# ============================================================
#  NexAPI — Automated Lab Setup Script
#  Nex-Experience | Offensive Security Research
#  Author: Greg Ochieng (Primenexuss)
#  Version: 1.0.0
#  Description: Automated setup for vulnerable API lab environment
# ============================================================

set -e
set -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
  echo -e "${RED}"
  echo "  ███╗   ██╗███████╗██╗  ██╗ █████╗ ██████╗ ██╗"
  echo "  ████╗  ██║██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗██║"
  echo "  ██╔██╗ ██║█████╗   ╚███╔╝ ███████║██████╔╝██║"
  echo "  ██║╚██╗██║██╔══╝   ██╔██╗ ██╔══██║██╔═══╝ ██║"
  echo "  ██║ ╚████║███████╗██╔╝ ██╗██║  ██║██║     ██║"
  echo "  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝"
  echo -e "${NC}"
  echo -e "${CYAN}  NexAPI — Vulnerable API Lab Setup${NC}"
  echo -e "${CYAN}  Nex-Experience | Offensive Security Research${NC}"
  echo ""
}

log_info()    { echo -e "${GREEN}[+]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[-]${NC} $1"; }
log_section() { echo -e "\n${CYAN}[*] $1${NC}"; }

banner

log_warn "This application is intentionally vulnerable."
log_warn "DO NOT deploy on a public or production server."
echo ""

# ── Check Ruby ─────────────────────────────────────────────
log_section "Checking Ruby version"
if ! command -v ruby &>/dev/null; then
  log_error "Ruby not found. Install Ruby >= 3.2.0 and re-run."
  log_info "Visit: https://www.ruby-lang.org/en/downloads/"
  exit 1
fi
RUBY_VER=$(ruby -e 'puts RUBY_VERSION')
log_info "Ruby $RUBY_VER detected"

# Check minimum version
if ! ruby -e "exit Gem::Version.new('$RUBY_VER') >= Gem::Version.new('3.2.0')" 2>/dev/null; then
  log_error "Ruby version $RUBY_VER is too old. Minimum required: 3.2.0"
  exit 1
fi

# ── Check PostgreSQL ────────────────────────────────────────
log_section "Checking PostgreSQL"
if ! command -v psql &>/dev/null; then
  log_error "PostgreSQL not found. Install PostgreSQL >= 14 and re-run."
  log_info "Visit: https://www.postgresql.org/download/"
  exit 1
fi
PG_VER=$(psql --version | awk '{print $3}' | cut -d'.' -f1)
log_info "PostgreSQL $PG_VER detected"

# ── Install Gems ────────────────────────────────────────────
log_section "Installing Ruby gems"
gem install bundler --quiet
bundle install
log_info "Gems installed"

# ── Database Setup ──────────────────────────────────────────
log_section "Setting up database"
if ! rails db:create 2>/dev/null; then
  log_warn "Database may already exist, continuing..."
fi
rails db:migrate
if ! rails db:seed 2>/dev/null; then
  log_error "Database seeding failed. Please check your PostgreSQL configuration."
  exit 1
fi
log_info "Database created, migrated, and seeded"

# ── Done ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         NexAPI Lab Setup Complete!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
log_info "Start the server:  rails server -p 3000 -b 0.0.0.0"
log_info "API base URL:      http://localhost:3000/api/v1"
log_info "Admin endpoint:    http://localhost:3000/api/admin"
log_info "Legacy endpoint:   http://localhost:3000/api/v0"
echo ""
log_warn "Happy hacking. Stay ethical."
echo ""
