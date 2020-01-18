# SETTINGS
# ========

# The shells to try. Used for installation as well as testing.
# Must be filenames. Order by preference, from best to worst.
# Change PATH to use different versions of the same shell.
SHELLS		= dash oksh mksh bash zsh yash ksh sh

# Where to store test scripts and dtruss logs.
TEST_DIR	= test
SCPT_DIR	= $(TEST_DIR)/scripts
LOG_DIR		= $(TEST_DIR)/logs

# Environment variables that some tests unset. 
ASKPASS_ENV	= LPASS_ASKPASS SSH_ASKPASS
LPASS_ENV	= $$(env | cut -d= -f1 | grep -E ^LPASS)

# Runs all test scripts.
RUN_ALL = for X in "$(SCPT_DIR)/"*; do echo "$$X" >&2; "$$X" || break; done

# The tests.
TESTS	= test-default test-login test-no-agent test-no-agent-prime


# TARGETS
# =======

.POSIX:
.PHONY: prepare logout $(SHELLS) scripts $(TESTS) test dtruss install

test: $(TESTS)

prepare:
	mkdir -p $(SCPT_DIR) 

$(SHELLS): prepare
	printf -- '#!%s\n' `command -v "$@"` >"$(SCPT_DIR)/lpassh-add.$@"
	tail -n +2 lpassh-add >>"$(SCPT_DIR)/lpassh-add.$@"
	chmod +x "$(SCPT_DIR)/lpassh-add.$@"

scripts: $(SHELLS)

logout:
	lpass logout --force 2>/dev/null || :

test-default:
	lpass status >/dev/null 2>&1 || lpass login "${LPASSH_ADD_USERNAME}"
	VARS=$(LPASS_ENV); export $$VARS; unset $$VARS; \
	$(RUN_ALL)

test-login: logout
	unset LPASS_AGENT_DISABLE $(ASKPASS_ENV); \
	export LPASS_AGENT_DISABLE $(ASKPASS_ENV); \
	$(RUN_ALL)

test-no-agent: logout
	unset $(ASKPASS_ENV); \
	export $(ASKPASS_ENV) LPASS_ASKPASS='' LPASS_AGENT_DISABLE=1; \
	$(RUN_ALL)

test-no-agent-prime: logout
	unset $(ASKPASS_ENV); \
	export $(ASKPASS_ENV) LPASS_AGENT_DISABLE=0 \
		LPASSH_ADD_AGENT_DISABLE=1; \
	$(RUN_ALL)

dtruss: logout
	mkdir -p "$(LOG_DIR)"
	for X in "$(SCPT_DIR)/"*; do \
		case $$X in *.sh) continue; esac; \
		LOGFILE="$$(basename "$$X")-dtruss.log"; \
		sudo -E dtruss "$$X" >"$(LOG_DIR)/$$LOGFILE" 2>&1 || :; \
	done

manual:
	pandoc -o lpassh-add.1 -t man -s MANUAL.rst \
    		-M title=lpassh-add \
		-M date="$$(date '+%B %d, %Y')" \
		-M section=1

install:
	PATH="`getconf PATH`:$$PATH"; \
	for SHELL in $(SHELLS); do \
		"$$SHELL" </dev/null && break; \
	done; \
	"$$SHELL" install.sh
