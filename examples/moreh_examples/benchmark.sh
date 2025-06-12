
MODEL_DIR=${MODEL_DIR:-/app/models/llama-2-70b-hf/}
# MODEL_DIR=${MODEL_DIR:-/app/models/qwq-32b/}


# Define test cases
TEST_CASES=(
	"512 512 1 8 16 32 64"
    # "1024 1024 1 8 16 32 64"
    # "2048 1024 1 8 16 32 64"
    # "2560 1024 1 8 16 32 64"
    # "512 512 1 64"
    # "1024 1024 1 64"
    # "2048 1024 1 64"
    # "2560 1024 1 64"
    # "4096 1024 1 8 16 32 64"
    # "8192 1024 1 8 16 32 64"
    # "7168 1024 64"
    # "15360 1024 32 64"
    # "16384 1024 1 8 16 32"
    # "31744 1024 1 8 16 32"
    # "65536 1024 1 8 16"
    # "131768 1024 1 8"
)

SCALE=3
LOG_DIR="log"


# Create log directory if not exists
mkdir -p $LOG_DIR

EXP_NAME="$1"
if [ -n "$EXP_NAME" ]; then
    EXP_NAME="${EXP_NAME}_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "${LOG_DIR}/${EXP_NAME}"
    LOG_DIR="${LOG_DIR}/${EXP_NAME}"
fi


# Loop through test cases
for test_case in "${TEST_CASES[@]}"; do
    read -r ISL OSL CON <<< "$test_case"    
    for con in $CON; do
        num_prompt=$(($con * $SCALE))
        log_file="${LOG_DIR}/${ISL}_${OSL}_${con}_${num_prompt}"
	echo "Running test case: input_len=$ISL, output_len=$OSL, concurrency=$con, num_prompts=$num_prompt"
	vllm bench serve \
		--endpoint /v1/completions \
        --port 8001 \
		--model $MODEL_DIR \
		--max-concurrency $con \
		--dataset-name random \
		--random-input-len $ISL \
		--random-output-len $OSL \
		--num-prompts $num_prompt \
		--ignore-eos 2>&1 | tee $log_file
	echo "Test case completed: input_len=$ISL, output_len=$OSL, concurrency=$con, num_prompts=$num_prompt"
    echo "Log file: $log_file"
    echo "--------------------------------------------------"

    echo "Reset prefix caching..."
    curl -X POST -s http://localhost:8001/reset_prefix_cache -H "Content-Type: application/json"
    done
done