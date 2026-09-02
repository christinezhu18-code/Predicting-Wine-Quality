white <- read.csv("winequality-white.csv", sep = ";")
red <- read.csv("winequality-red.csv", sep = ";")

###PRELIM ANALYSIS
summary(white)
summary(red)
colnames(white)
colnames(red)
dim(white)
dim(red)

hist(white$quality)
hist(red$quality)

install.packages("corrplot")
library(corrplot)
cor_white <- cor(white)
corrplot(cor_white, method = "color", 
         tl.cex = 0.8,
         title = "White Wine Correlation Heatmap",
         mar = c(0,0,1,0))
cor_red <- cor(red)
corrplot(cor_red, method = "color",
         tl.cex = 0.8, 
         title = "Red Wine Correlation Heatmap",
         mar = c(0,0,1,0))

#split into training(90%) and testing set (10%)
subset_white <- sample(nrow(white), nrow(white) * 0.9)
white_train = white[subset, ]
white_test = white[-subset, ]

subset_red <- sample(nrow(red), nrow(red) * 0.9)
red_train = red[subset, ]
red_test = red[-subset, ]

####METHOD 1) LINEAR REGRESSION 
##benchmark model 
model_white <- lm(quality ~ ., data=white_train)
summary(model_white)

model_red <- lm(quality ~ ., data=red_train)
summary(model_red)

#in-sample model evaluation
model_summary1 <- summary(model_white)
(model_summary1$sigma)^2
model_summary1$r.squared
model_summary1$adj.r.squared
AIC(model_white)
BIC(model_white)

model_summary2 <- summary(model_red)
(model_summary2$sigma)^2
model_summary2$r.squared
model_summary2$adj.r.squared
AIC(model_red)
BIC(model_red)

#out of sample model eval
pi <- predict(object = model_white, newdata = white_test)
mean((pi - white_test$quality)^2) #MSE = 0.5940786
mean(abs(pi - white_test$quality)) #MAE = 0.5958942  

#best subset variable selection
install.packages("leaps")
library(leaps)
subset_result1 <- regsubsets(quality ~ ., data = white_train,
                            nbest = 2, nvmax = 14) 
summary(subset_result1)
plot(subset_result1, scale = "bic")

subset_result2 <- regsubsets(quality ~ ., data = red_train,
                            nbest = 2, nvmax = 14)
summary(subset_result2)
plot(subset_result2, scale = "bic")

#white wine model 2 
model2_white <- lm(quality ~ fixed.acidity + volatile.acidity + residual.sugar + free.sulfur.dioxide + density + pH + sulphates, 
                    data = white_train)
model2_white_summary <- summary(model2_white)
model2_white_summary
#Eval white model 2 
(model2_white_summary$sigma)^2 #MSE 
model2_white_summary$adj.r.squared 
AIC(model2_white) 
BIC(model2_white)

#red wine model 2 
model2_red <- lm(quality ~ volatile.acidity + chlorides + total.sulfur.dioxide + pH + sulphates + alcohol, 
                   data = red_train)
model2_red_summary <- summary(model2_red)
model2_red_summary
#Eval red model 2 
(model2_red_summary$sigma)^2 #MSE 
model2_red_summary$adj.r.squared
AIC(model2_red)
BIC(model2_red)

#5 fold cross validation on og data
library(boot)
model2_white = glm(quality ~ fixed.acidity + volatile.acidity + residual.sugar + free.sulfur.dioxide + density + pH + sulphates, 
                   data = white)
cv.glm(data = white, glmfit = model2_white, K = 5)$delta[2]

model2_red = glm(quality ~ volatile.acidity + chlorides + total.sulfur.dioxide + pH + sulphates + alcohol, 
                 data = red)
cv.glm(data = red, glmfit = model2_red, K = 5)$delta[2]

plot(model2_white)
plot(model2_red)

###METHOD 2) REGRESSION TREE
install.packages('rpart')
install.packages('rpart.plot')
library(rpart)
library(rpart.plot)

white_rpart <- rpart(formula = quality ~ ., data = white_train)
white_rpart
prp(white_rpart,digits = 4, extra = 1)

red_rpart <- rpart(formula = quality ~ ., data = red_train)
red_rpart
prp(red_rpart,digits = 4, extra = 1)

#in sample MSE 
white_train_pred_tree = predict(white_rpart)
white_MSE_tree<- mean((white_train_pred_tree - white_train$quality)^2)
white_MSE_tree

red_train_pred_tree = predict(red_rpart)
red_MSE_tree<- mean((red_train_pred_tree - red_train$quality)^2)
red_MSE_tree

#Out of sample MSPE (test set)
white_test_pred_tree = predict(white_rpart,white_test)
MSPE.tree_white <- mean((white_test_pred_tree - white_test$quality)^2)
MSPE.tree_white 

red_test_pred_tree = predict(red_rpart,red_test)
MSPE.tree_red <- mean((red_test_pred_tree - red_test$quality)^2)
MSPE.tree_red 

#compare tree vs linear reg model fit (out of samp) 
white_test_pred_reg = predict(model_white, white_test)
mean((white_test_pred_reg - white_test$quality)^2) #MSE = 0.5940786

red_test_pred_reg = predict(model_red, red_test)
mean((red_test_pred_reg - red_test$quality)^2) #MSE = 0.390562

###METHOD 3) RANDOM FOREST
install.packages("randomForest")
library(randomForest)

#white random forest
rf_white <- randomForest(quality ~ ., data = white_train, ntree = 500)
print(rf_white) #shows in sample MSE
plot(rf_white)
varImpPlot(rf_white)
#out of sample testing
pred_rf_white <- predict(rf_white, white_test)
mean((pred_rf_white - white_test$quality)^2)  # MSE

#red random forest
rf_red <- randomForest(quality ~ ., data = red_train, ntree = 500)
print(rf_red) #shows in sample MSE
plot(rf_red)
varImpPlot(rf_red)
#out of sample testing 
pred_rf_red <- predict(rf_red, red_test)
mean((pred_rf_red - red_test$quality)^2)  # MSE
