# databrary-dev-learning
Repo for learning Databrary code base

* MonadHas pattern (see Identity.Types)
* Kinded
  * paths, solr, enum, ingest.json
* Functions in Identity.Types
* Model.Enum, makeDbEnum
* Controller related examples
* Template Haskell basics example - started,
  * what happens if a record has two fields of same type (Car with front tire, back tire)
  * why are only some of the Model record fields strict?
  * deriveLiftMany (Metric.Types)
  * volumeaccess makehasfor?
  * peek
* Example using postgresql-typed
  * pgparam, pgcolumn
  * range
  * makePGQuery
  * PGQuery
  * Model.SQL & Model.SQL.Select
* Service.DB exposed functions
* MonadDB, MonadHasIdentity
* MonadHasRequest, MonadAudit, MonadHas Secret
* Example demonstrating each operator in Ops
* Example using deriveLift (see Model.Format)
* Generate Angular and serve
* web-inv-route example
  * R.Paramter R.PathString a
* Basic warp example
* Generate Angular and serve
* Exception usage
* Store.Config
* Action.*
* HTTP*