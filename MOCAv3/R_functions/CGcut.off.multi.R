CGcut.off.multi<-function(controls_data=NULL, model = NULL, preds = NULL,  Yobs = NULL, p.crit=0.05, upper=FALSE){
  
  # ver 0.3, 15/11/2021
  
  # MULTIVARIATE VERSION OF CG CUT-OFF
  
  # - controls_data = a matrix or data.frame with the data from controls (each row a participant, each col a variable)
  # - model = a lm object (i.e., a linear model fitted with lm) for the data correction
  # - preds = a vector with a value for each variable in the model
  # - Yobs = OPTIONAL, the observed y. If not specified the function return the critical t and Y associated with the p.crit
  # - p.crit = the critical p.values. It is used only if Yobs is not specified.
  
  #######################
  # PERFORM SOME CHECKS #
  #######################
  if (is.null(model)){
    stop("you should specify a regression model (model), calculated on controls data")
  }
  
  if (is.null(controls_data)){
    stop("you should specify a the controls data, on which the model is calculated")
  }
  
  if (is.null(preds)){
    stop("you should include the values of the predictors")
  }
  
  if (length(preds)!=dim(controls_data)[2]){
    stop("the length of predictor values should be the same of the number of columns of controls_data")
  }
  
  
  if(any(is.na(controls_data))){
    controls_data=na.omit(controls_data)
    warning("The dataset included some NA. na.omit() has been applied to the data.", call.=F)
  }
  
  
  sigma = summary(model)$sigma 
  
  # calculate n of observation of controls (i.e., numbers of control subjects)
  n = dim(controls_data)[1]
  
  # calculate number of variables (i.e., number of predictors)  
  nvar=dim(controls_data)[2] # numero variabili
  
  # calculate mean ov all variables
  vars_mean = apply(controls_data, 2, mean)  
  
  rmat=cor(controls_data) # correlation matrix
  rinv=solve(rmat) # l'inverted correlation matrix (needed for the la formula)
  rinv.diag=diag(rinv) # elementi nella diagonale.
  rinv.offdiag=rinv[upper.tri(rinv)]
  
  # loop to calculate needed k (variables)
  
  zio = rep(0, nvar)
  
  for (i in 1:nvar){
    zio[i] = ((n-1)*(preds[i]-vars_mean[i]))/sum((controls_data[,i]-vars_mean[i])^2)
  }
  
  zio_2 = zio^2
  ## I call A and B, the first and second sum within Eq. 6
  # transform the Sum in matrix multiplication (I checked and it is correct)
  # A=zio_2[1]*rinv.diag[1]+zio_2[2]*rinv.diag[2]
  
  A=rinv.diag%*%zio_2 # this generalize to every length of zio_2
  
  # to obtain B, first I creat a mtrix with all possible multiplication between z
  # to to dhat I use the cross-product function %o%
  
  zio_2_multi=zio_2%o%zio_2
  
  # isolate off.diag elements
  zio_2_multi.offdiag=zio_2_multi[upper.tri(zio_2_multi)]
  
  B=rinv.offdiag%*%zio_2_multi.offdiag
  
  Sn_1=sigma*(sqrt( 1 + ( 1/n ) + ( 1/(n-1) ) * A + ( 2/(n-1) ) * B ))
  
  # find critical t and then the result
  newdata =  as.list(preds)
  names(newdata) = names(model$coefficients)[-1] # get the names of predictors from the coeff of the lm model
  Y_pred=predict(model, newdata=newdata)
  df=(n-nvar-1)  # see fourth lines of p. 262 (C&G 2006)
  t.crit=qt(p=p.crit, df=df) # note I use 0.05
  
  if (upper==TRUE){
    t.crit = -t.crit
  }
  
  # the following formula is formula (3) by Crawford and Garthwaite 2006, inverted. 
  # In the original formula, the ouput value is the observed t.
  Y_obs_crit=(t.crit*Sn_1)+Y_pred 
  
  t.obs = (Yobs - Y_pred)/Sn_1
  
  if (upper==FALSE){
    p.obs=pt(t.obs, df = df) # taken from p.262 line 5.
  }
  
  if (upper==TRUE){
    p.obs=1-pt(t.obs, df = df)
  }
  
  
  
  ##################
  # create results #
  ##################
  
  if (!is.null(Yobs)){
    res = data.frame(Yobs = Yobs, t.obs=t.obs,  df = df, p.obs = p.obs, t.crit=t.crit, p.crit=p.crit)
  } 
  
  if (is.null(Yobs)){
    res = data.frame(Y_obs_crit = Y_obs_crit, t.crit = t.crit, df=df, p.crit=p.crit)
  }
  return(res)
}