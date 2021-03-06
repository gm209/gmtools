#' train_xgboost
#'
#' A wrapper function that automates the xgboost training process
#' @param data                   A data.frame (or coercible object) that contains the training data
#' @param x                      A list of column names that identify the explanatory features 
#' @param y                      A column name that identifies that target variable
#' @param w                      A column name that contains the name of the weight column. Defaults to NULL
#' @param w                      A column name that contains the name of the offset column. Defaults to NULL
#' @keywords create dmatrix
#' @import xgboost
#' @export
#' @examples
#' 

xgb_create_dmatrix <- function(data,x,y=NULL,w=NULL,base_margin=NULL){

  ## Make sure input is a data.frame
  if(class(data)[1] != 'data.frame') data = as.data.frame(data)

  ## Create the labels
  if(is.null(y)) label = rep(1,nrow(data))  else  label = data[,y]

  ## Deal with null weights
  if(is.null(w)) weight = rep(1,nrow(data)) else weight = data[,w]

  ## Now Convert the data to a dmatrix
  dmat = xgb.DMatrix(data = as.matrix(data[,x]),label = label,weight = weight)

  ## Add an offset if required
  if(!is.null(base_margin)) setinfo(dmat,"base_margin",data[,base_margin])
  
  ## Return the result
  return(dmat)

}

#' train_xgboost
#'
#' A wrapper function that automates the xgboost training process
#' @param dtrain                 A data.frame that contains the training data
#' @param dvalid                 A data.frame that contains the validation data. If NULL then the function uses cross validation. Defaults to NULL.
#' @param x                      A list of column names that identify the explanatory features 
#' @param y                      A column name that identifies that target variable
#' @param w                      A column name that contains the name of the weight column. Defaults to NULL
#' @param xgbParams              A named list containing the XGBoost Learning Parameters
#' @param nrounds                The maximum number of iterations 
#' @param early_stopping_rounds  If performance doesnt improve for this many rounds then stop training
#' @param nfold                  How many folds to use if doing cross validation   
#' @param folds                  A list of pre defined fold indicies (test indicies) - see main xgboost docs for more details.
#' @param verbose                Print run time messages  
#' @param seed                   An integer which will be used as the random seed. Defaults to 1921
#' @param ...                    Additional Arguments to be passed to xgb.cv and/or xgb.train     
#' @keywords train xgboost
#' @import xgboost
#' @export
#' @examples
#' 

train_xgboost <- function(dtrain,dvalid=NULL,x,y,w=NULL,base_margin=NULL,xgbParams,nrounds=5000,early_stopping_rounds=5,nfold = 5,folds=NULL,verbose=TRUE,seed=1921,...){
      
  ## Are we doing CV?
  is_cv = is.null(dvalid)
  null_weights = is.null(w)
  
  ## Make sure input is data.frame & deal with null weights
  if(verbose) message('>>>>> Checking data')
  dtrain = as.data.frame(dtrain)

  ## Create the various matricies
  if(verbose) message('>>>>> Creating Matricies')
  dtrain = xgb_create_dmatrix(data = dtrain,x = x,y = y,w = w,base_margin = base_margin)
  if(!is_cv) { dvalid = as.data.frame(dvalid)
               dvalid = xgb_create_dmatrix(data = dvalid,x = x,y = y,w = w,base_margin = base_margin) }
   
  ## If we're doing CV pick nrounds
  if(is_cv){ if(verbose) message('>>>>> Fitting CV Model')
             set.seed(seed)
             xgbCV = xgboost::xgb.cv(params  = xgbParams,
                                     data    = dtrain,
                                     nrounds = nrounds,
                                     early_stopping_rounds = early_stopping_rounds,
                                     nfold   = nfold,
                                     folds   = folds,
                                     verbose = verbose,
                                     prediction = TRUE,
                                     ...) } else xgbCV = NULL 
  
  ## Sort out the parameters
  if(verbose) message('>>>>> Extracting Parameters')
  opt_nrounds = ifelse(is_cv,xgbCV$best_iteration,nrounds)
  watchlist = if(is_cv) list(train = dtrain) else list(train = dtrain,valid = dvalid)
  early_stopping_rounds = if(is_cv) NULL else early_stopping_rounds
 
  ## Now train the final model
  if(verbose) message('>>>>> Training Final Model')
  set.seed(seed)
  finalModel = xgboost::xgb.train(params    = xgbParams,
                                  data      = dtrain,
                                  nrounds   = opt_nrounds,
                                  watchlist = watchlist,
                                  early_stopping_rounds = early_stopping_rounds,
                                  verbose = verbose,
                                  ...)
  
  ## Return final model
  return(list(finalModel=finalModel,
              xgbCV = xgbCV,
              dtrain=dtrain,
              dvalid=dvalid,
              fin_early_stopping_rounds = early_stopping_rounds,
              opt_nrounds=opt_nrounds,
              is_cv = is_cv,
              null_weights=null_weights))
}