
SHELLS		= sh dash ksh bash zsh yash

TEST_DIR	= test
SCPT_DIR	= $(TEST_DIR)/scripts
LOG_DIR		= $(TEST_DIR)/logs

ASKPASS_ENV	= LPASS_ASKPASS SSH_ASKPASS
LPASS_ENV	= $$(env | cut -d= -f1 | grep -E ^LPASS)

RUN_ALL = for X in "$(SCPT_DIR)/"*; do echo "$$X" >&2; "$$X" || break; done

TESTS	= test-default test-login test-no-agent test-no-agent-prime

.POSIX:
.PHONY: prepare logout scripts $(SHELLS) $(TESTS) dtruss

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

test-default: logout
	lpass status >/dev/null 2>&1 || lpass login "${LPASSH_ADD_USERNAME}"
	VARS=$(LPASS_ENV); export $$VARS; unset $$VARS; \
	$(RUN_ALL)

test-login: logout
	unset LPASS_AGENT_DISABLE $(ASKPASS_ENV); \
	export LPASS_AGENT_DISABLE $(ASKPASS_ENV); \
	$(RUN_ALL)

test-no-agent: logout
	unset $(ASKPASS_ENV); \
	export $(ASKPASS_ENV) LPASS_ASKPASS=''
	LPASS_AGENT_DISABLE=1; \
	$(RUN_ALL)

test-no-agent-prime: logout
	unset $(ASKPASS_ENV); \
	export $(ASKPASS_ENV) LPASS_ASKPASS='' \
	LPASS_AGENT_DISABLE=0 LPASSH_ADD_AGENT_DISABLE=1; \
	$(RUN_ALL)

dtruss: logout
	mkdir -p "$(LOG_DIR)"
	for X in "$(SCPT_DIR)/"*; do \
		LOGFILE="$$(basename "$$X")-dtruss.log"; \
		case $$X in *.sh) continue; esac; \
		sudo -E dtruss "$$X" >"$(LOG_DIR)/$$LOGFILE" 2>&1 || :; \
	done
