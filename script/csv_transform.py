import sys
import urllib
from pyspark.sql import SparkSession
from pyspark.sql.functions import \
    col, \
    split, \
    concat_ws, \
    concat, \
    date_format, \
    lit


def main():
    input_bucket = sys.argv[1]
    input_key = urllib.parse.unquote_plus(sys.argv[2])
    input_path = f"s3://{input_bucket}/{input_key}"
    output_bucket = sys.argv[3]
    output_key = urllib.parse.unquote_plus(sys.argv[4])
    output_path = f"s3://{output_bucket}/{output_key}"

    print(f"Input path: {input_path}")
    print(f"Output path: {output_path}")

    spark = SparkSession.builder.appName("S3 to EMR Serverless Processing").getOrCreate()

    # S3からCSVファイルを読み込む
    df = spark.read.option("encoding", "Shift_JIS").csv(input_path, header=True, inferSchema=True)
    # split_consultday = split(col("consultday"), " ")

    # データ処理（例：列の追加）
    df_modified = df \
        .withColumn("created_at", date_format(col("created_at"), "yyyy-MM-dd")) \

    # 列名の変更
    df_modified = df_modified \
        .withColumnRenamed("id", "ID") \
        .withColumnRenamed("age", "年齢") \
        .withColumnRenamed("created_at", "登録日時")

    # データ処理（例：特定の列を選択）
    processed_df = df_modified.select("ID",
                                      "年齢",
                                      "登録日時",)

    # 処理結果をS3に保存
    processed_df.write.option("encoding", "UTF-8").csv(output_path, header=True, mode="overwrite")

    spark.stop()


if __name__ == "__main__":
    main()
