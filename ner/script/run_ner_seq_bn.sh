#!/bin/bash
MODEL="indolem/indobert-base-uncased"
TRAIN_BATCH_SIZE=16
EVAL_BATCH_SIZE=64
NUM_EPOCHS=100
LEARNING_RATE=5e-5
MAX_LENGTH=128
SEED=42

DATA_DIR=./data/$DATASET

for i in {0..4}
do
    echo "Training on fold $i with Seq Bottleneck (Adapter)"

    OUTPUT_DIR="bin/$DATASET-seq_bn-$i"
    TRAIN_FILE="$DATA_DIR/train$i.csv"
    VALIDATION_FILE="$DATA_DIR/dev$i.csv"
    TEST_FILE="$DATA_DIR/test$i.csv"

    python run_ner.py \
        --model_name_or_path $MODEL \
        --label_names "labels" \
        --text_column_name "tokens" \
        --label_column_name "ner_tags" \
        --output_dir $OUTPUT_DIR \
        --train_file $TRAIN_FILE \
        --validation_file $VALIDATION_FILE \
        --test_file $TEST_FILE \
        --num_train_epochs $NUM_EPOCHS \
        --per_device_train_batch_size $TRAIN_BATCH_SIZE \
        --per_device_eval_batch_size $EVAL_BATCH_SIZE \
        --learning_rate $LEARNING_RATE \
        --max_seq_length $MAX_LENGTH \
        --seed $SEED \
        --return_entity_level_metrics \
        --evaluation_strategy "epoch" \
        --logging_strategy "epoch" \
        --save_strategy "epoch" \
        --save_total_limit 1 \
        --report_to "wandb" \
        --push_to_hub \
        --project_name "indolem-pelt-$DATASET" \
        --group_name "seq_bn" \
        --job_type "fold-$i" \
        --run_name "$DATASET-seq_bn-$i" \
        --do_train \
        --do_eval \
        --do_predict \
        --overwrite_output_dir \
        --adapter_config "seq_bn" \
        --train_adapter \

    echo "Finished training on fold $i with Seq Bottleneck (Adapter)"
done
