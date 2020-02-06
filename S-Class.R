library(mosaic)

sclass = read.csv('sclass.csv', head=1)
summary(sclass)

ggplot(data = sclass) + 
  geom_point(mapping = aes(x = price, y = mileage), color='darkgrey') + 
  ylim(7000, 20000)

sclass550 = subset(sclass, trim == '350')
dim(sclass550)
sclass65AMG = subset(sclass, trim == '65 AMG')
summary(sclass65AMG)

# Look at price vs mileage for each trim level
plot(price ~ mileage, data = sclass550)
plot(price ~ mileage, data = sclass65AMG)

# Make a train test split
N = nrow(sclass550)
N_train = floor(0.8*N)
N_test = N - N_train

# select random sample to include in the training set
train_ind = sample.int(N, N_train, replace=FALSE)

# Formalise training and testing sets
D_train = sclass550[train_ind,]
D_test = sclass550[-train_ind,]

#housekeeping, just arrange as per mileage
D_test = arrange(D_test, mileage)
head(D_test)

# Seperate training and testing sets into features (mileage: X) and outcome (price: y)
X_train = select(D_train, mileage)
y_train = select(D_train, price)
X_test = select(D_test, mileage)
y_test = select(D_test, price)

lm = lm(price ~ poly(mileage, 2), data=D_train)
ypred_lm2 = predict(lm, D_test)
p_test = ggplot(data = D_test) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
  theme_bw(base_size=18)
p_test
p_test + geom_path(aes(x = mileage, y = ypred_lm2), color='blue')

rsme = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

knn250 = knn.reg(train = X_train, test = X_test, y = y_train, k=250)
3

knn_resultpred <- c(1:84)
knn_resultpred = as.data.frame(knn_resultpred)

i=3
for(i in 3:nrow(X_train)) {
  knn_mod = knn.reg(train = X_train, test = X_test, y = y_train, k=i)
  ypred_knn = knn_mod$pred
  knn_resultpred = cbind(knn_resultpred,ypred_knn)
}

names(knn_resultpred) = c("N",3:332)
knn_resultpred = subset(knn_resultpred[2:332])

knn_resultrsme = data.frame(K=c(),rsme=c())
i=3
for(i in 3:nrow(X_train)) {
  knn_mod = knn.reg(train = X_train, test = X_test, y = y_train, k=i)
  ypred_knn = knn_mod$pred
  rsme_knn = rsme(y_test, ypred_knn) 
  knn_resultrsme =  rbind(knn_resultrsme, c(i,rsme_knn))
}

names(knn_resultrsme) = c("K", "rsme")

k_min = with(knn_resultrsme, K[rsme == min(rsme)])

ggplot(data = knn_resultrsme) + 
geom_point(mapping = aes(x = K, y = rsme), color='lightgrey') + 
theme_bw(base_size=18) +
geom_vline(xintercept = k_min, 
               color = "purple", size=1)

pred_knn = knn_resultpred$"19"
pred_knn = as.data.frame(pred_knn)
D_test = arrange(D_test, mileage)
pred_knn = mutate(pred_knn, mileage = D_test$mileage)
pred_knn = mutate(pred_knn, price = D_test$price)

ggplot(data = pred_knn) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
  theme_bw(base_size=18) +
  geom_path(aes(x = mileage, y = pred_knn), color='blue')





##### FROM HERE DOWN I DIDN'T CHECK ####





Kmin = KNN_result$K[which.min(KNN_result$RSME)]
P_KNNresult_350 = ggplot(data = KNN_result)+
  geom_line(aes(x = K, y = RSME))+
  geom_line(aes(x = Kmin, y = RSME), col = "blue")+
  theme_bw()+
  labs(title = "K vs RSME(Trim Level: 350)")+
  theme(plot.title = element_text(hjust = 0.1))
P_KNNresult_350

##
  knn_K = knn.reg(train = X_train, test = X_test, y = y_train, k=i)
  ypred_knn = knn_K$pred
  KNN_rsme = rmse(y_test, ypred_knn)
  KNN_result <- rbind(KNN_result,c(i,KNN_rsme))
  
colnames(KNN_result) = j("K","RSME")
Kmin = KNN_result$K[which.min(KNN_result$RSME)]
P_KNNresult_350 = ggplot(data = KNN_result)+
  geom_line(aes(x = K, y = RSME))+
  geom_line(aes(x = Kmin, y = RSME), col = "blue")+
  theme_bw()+
  labs(title = "K vs RSME(Trim Level: 350)")+
  theme(plot.title = element_text)
P_KNNresult_350
rmse(y_test, ypred_lm1)
rmse(y_test, ypred_knn250)

# Optimal K for 350 trim:
print(Kmin)

# As we are taking random samples, we might get varying KNN resuts. But on average the optimal trim level is 20
#{r s350p_optimalplot, echo=FALSE, warning=FALSE, fig.align='center'}
knn_K = knn.reg(train = X_train, test = X_test, y = y_train, k=Kmin)
ypred_knn = knn_K$pred
D_test$ypred_knn = ypred_knn
p_test_350 = ggplot(data = D_test) + 
  geom_point(mapping = aes(x = mileage, y = price), color='black') + 
  geom_path(mapping = aes(x = mileage, y = ypred_knn), color='blue') +
  theme_bw()+
  labs(title = "Fitted Model(Trim Level: 350) at K=20")+
  theme(plot.title = element_text)
p_test_350

# Now we repeat the same KNN methodology for the 65 AMG trim level. Here is the plot for mileage vs price for the 65 AMG trim level:
