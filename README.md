# EMR-Redshift Serverless Terraform

## 概要
このリポジトリは、AWS EMRとRedshiftをTerraformで構築するためのコードです。

## 前提条件
- Terraform v0.12+ がインストールされていること
- AWSアクセスキーとシークレットキーが設定されていること
- AWS CLIが設定されていること（任意）

## セットアップ
1. このリポジトリをクローンします：

```bash
git clone https://github.com/TodoONada/redshift-emr-infra
```

2. クローンしたディレクトリに移動します：

```bash
cd redshift-emr-infra
```

3. Terraformの初期化を行う

```bash
terraform init -reconfigure -backend-config=backends/sample.tfbackend
```

## Stateの管理
このプロジェクトのTerraform StateはAWS S3で管理されています。

- **バケット名**:sample-terraform-state
- **キー**: redshift-emr-infra/terraform.tfstate

## environmentsの準備

environments/sample.tfvarsを作成し、以下の内容を記述します。

## pyspark_ge.tar.gzの作成

EMRのSparkジョブを実行するためのPythonライブラリを作成するために、以下の手順でpyspark_ge.tar.gzを作成します。

```
cd emr_python_library
docker build --output . .
```

## AWSへApply
- **プラン**: Terraformで行われる変更をプレビューします。

```bash
terraform plan -var-file=environments/sample.tfvars
```

- **適用**: 定義されたインフラストラクチャを作成または更新します。

```bash
terraform apply -var-file=environments/sample.tfvars
```

## Redshiftのテーブルを作成

Redshiftに接続して、テーブルを作成してください。
``redshift/sample.sql``にサンプルがあります。

## EMRの変換スクリプト

EMRのジョブの変換スクリプトを作成してください。
``script/csv_transform.py``にサンプルがあります。

## EMRのジョブの実行の停止コマンド

```
aws emr-serverless stop-application --application-id "application_1630480000000_0001"
```

