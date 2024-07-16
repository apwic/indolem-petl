#!/bin/bash
declare -a ranks=("8" "16")

for i in {0..4}
do
	for rank in "${ranks[@]}"
	do
		echo "Training on fold $i with LoRA r=$rank"

		OUTPUT_DIR="bin/$DATASET-lora-$i"
		TRAIN_FILE="$DATA_DIR/train.0$((i + 1)).jsonl"
		VALIDATION_FILE="$DATA_DIR/dev.0$((i + 1)).jsonl"
		TEST_FILE="$DATA_DIR/test.0$((i + 1)).jsonl"

		python run_summarization.py \
			--model_name_or_path $MODEL \
			--lang "id" \
			--text_column "paragraphs" \
			--summary_column "summary" \
			--output_dir $OUTPUT_DIR \
			--train_file $TRAIN_FILE \
			--validation_file $VALIDATION_FILE \
			--test_file $TEST_FILE \
			--num_train_epochs $NUM_EPOCHS \
			--per_device_train_batch_size $TRAIN_BATCH_SIZE \
			--per_device_eval_batch_size $EVAL_BATCH_SIZE \
			--learning_rate $LEARNING_RATE \
			--weight_decay $WEIGHT_DECAY \
			--num_beams $NUM_BEAMS \
			--patience $PATIENCE \
			--optim "adamw_torch_fused" \
			--max_source_length $MAX_LENGTH \
			--max_target_length $MAX_LENGTH \
			--generation_max_length $MAX_LENGTH \
			--pad_to_max_length \
			--seed $SEED \
			--bf16 \
			--predict_with_generate \
			--evaluation_strategy "epoch" \
			--logging_strategy "epoch" \
			--save_strategy "epoch" \
			--save_total_limit 1 \
			--load_best_model_at_end \
			--metric_for_best_model "rouge1" \
			--report_to "wandb" \
			--push_to_hub \
			--project_name "indolem-pelt-$DATASET" \
			--group_name "lora-r${rank}" \
			--job_type "fold-$i" \
			--run_name "$DATASET-lora-r${rank}-$i" \
			--do_train \
			--do_eval \
			--do_predict \
			--overwrite_output_dir \
			--adapter_config "lora[r=$rank]" \
			--train_adapter

		echo "Finished training on fold $ with LoRA r=$rank"
	done
done
