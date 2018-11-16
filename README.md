# slack-wormhole
Connect a slack team and others

## Requirements

- GCP Account & Credential
- Ruby
- Bundle
- Slack API Token

## Installation

```
$ git clone https://github.com/Mahito/slack-wormhole.git
$ cd slack-wormhole
$ gem install bundle
$ bundle install --path vendor/bundle
```

## Configuring

### Google Cloud PubSub

1. PublishするためのTopicを作成. 1 Slack teamごとに１つ作成を行う.
2. SubscribeするTopicにSubscriptionを作成.
   複数チームをSubscribeするのであれば複数のTopicにSubscriptionを作成すること.

### Google Cloud Datastore

1. WORMHOLE_ENTITY_NAMEと同じ名前のエンティティを作成
2. 各種プロパティは以下の通り

|Name|Type|Value|Indexing|
|--|--|--|--|
|channelID|string||true|
|originalTs|string||true|
|timestamp|string||true|
|user|string||true|

### Environment Variables

|Env|Value|Description|
|--|--|--|
|SLACK_API_TOKEN|string|Slack API token|
|GCP_PROJECT_ID|string|Project ID of GCP|
|GOOGLE_APPLICATION_CREDENTIALS|string|Path to GCP credential|
|WORMHOLE_TOPIC_NAME|string|Topic Name for publish at Cloud PubSub|
|WORMHOLE_SUBSCRIPTION_NAMES|string|Subscriptuon names for subscribe at Cloud PubSub|
|WORMHOLE_ENTITY_NAME|string|Entity name at Cloud Datastore|
|WORMHOLE_ALLOW_CHANNELS|string|Channel names that allow receiving|

## Quick Start

```
$ export SLACK_API_TOKEN=xxxxxxxxxxxx
$ export GCP_PROJECT_ID=xxx-xxxx
$ export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credential
$ export WORMHOLE_TOPIC_NAME=topic_name
$ export WORMHOLE_ENTITY_NAME=entiti_name
$ export WORMHOLE_SUBSCRIPTION_NAMES=subscription1,subscription2,subscription3
$ export WORMHOLE_ALLOW_CHANNELS=general,random,wormhole
$ bundle exec ruby lib/slack_wormhole.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/Mahito/slack-wormhole.git

## Development

```
$ git clone https://github.com/Mahito/slack-wormhole.git
$ cd slack-wormhole
$ gem install bundle
$ bundle install --path vendor/bundle
$ bundle exec ruby lib/slack_wormhole.rb
```
