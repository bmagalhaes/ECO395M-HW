library(mosaic)
library(FNN)

sclass = read.csv('sclass.csv', head=1)
summary(sclass)

sclass550 = subset(sclass, trim == '350')
dim(sclass550)
sclass65AMG = subset(sclass, trim == '65 AMG')
summary(sclass65AMG)

plot(price ~ mileage, data = sclass550, main = "Price vs Mileage for SClass350")
plot(price ~ mileage, data = sclass65AMG, main = "Price vs Mileage for SClass65AMG")

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

ggplot(data = D_test) + 
geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
theme_bw(base_size=18) + geom_path(aes(x = mileage, y = ypred_lm2), color='red') +
labs(title = "Linear Model's price prediction for SClass350")+
theme(plot.title = element_text(hjust = 0.5))

rsme = function(y, ypred) {
  sqrt(mean(data.matrix((y-ypred)^2)))
}

knn_resultpred <- c(1:84)
knn_resultpred = as.data.frame(knn_resultpred)

i=3
for(i in 3:nrow(X_train)) {
  knn_mod = knn.reg(train = X_train, test = X_test, y = y_train, k=i)
  ypred_knn = knn_mod$pred
  knn_resultpred = cbind(knn_resultpred,ypred_knn)
}

vector_1 = c("N",3:332)
vector_1 = sub("^", "K", vector_1)
colnames(knn_resultpred) <- vector_1

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
  geom_vline(xintercept = k_min, color = "purple", size=1) +
  labs(title = "RSME vs K for SClass350") +
  theme(plot.title = element_text(hjust = 0.5))

knn_min = knn.reg(train = X_train, test = X_test, y = y_train, k=k_min)
ypred_knn = as.data.frame(knn_min$pred)
names(ypred_knn) = c("ypred_knn")

D_test = arrange(D_test, mileage)
ypred_knn = mutate(ypred_knn, mileage = D_test$mileage)
ypred_knn = mutate(ypred_knn, price = D_test$price)
ypred_knn = mutate(ypred_knn, ypred_knn3 = knn_resultpred$K3)
ypred_knn = mutate(ypred_knn, ypred_knn75 = knn_resultpred$K75)
ypred_knn = mutate(ypred_knn, ypred_lm = ypred_lm2)

ggplot(data = ypred_knn) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
  theme_bw(base_size=18) +
  geom_path(aes(x = mileage, y = ypred_knn, colour='KNN Min'), size=1.5) +
  geom_path(aes(x = mileage, y = ypred_knn3, colour='KNN 3')) +
  geom_path(aes(x = mileage, y = ypred_knn75, color='KNN 75')) +
  geom_path(aes(x = mileage, y = ypred_lm, color='Linear Model')) +
  scale_color_discrete(name = "Models")+
  labs(title = "Multiple price prediction for SClass350") +
  theme(plot.title = element_text(hjust = 0.5)) 

##### NOW FOR THE OTHER CAR MODEL (65AMG) ####

M = nrow(sclass65AMG)
M_train = floor(0.8*M)
M_test = M - M_train

# select random sample to include in the training set
train_ind2 = sample.int(M, M_train, replace=FALSE)

# Formalise training and testing sets
E_train = sclass65AMG[train_ind2,]
E_test = sclass65AMG[-train_ind2,]

#housekeeping, just arrange as per mileage
E_test = arrange(E_test, mileage)
head(E_test)

# Seperate training and testing sets into features (mileage: X) and outcome (price: y)
X2_train = select(E_train, mileage)
y2_train = select(E_train, price)
X2_test = select(E_test, mileage)
y2_test = select(E_test, price)

lm2 = lm(price ~ poly(mileage, 2), data=E_train)
ypred_lm22 = predict(lm2, E_test)

ggplot(data = E_test) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
  theme_bw(base_size=18) + geom_path(aes(x = mileage, y = ypred_lm22), color='blue') +
  labs(title = "Linear Model's price prediction for SClass65AMG")+
  theme(plot.title = element_text(hjust = 0.5))

knn_resultpred2 <- c(1:59)
knn_resultpred2 = as.data.frame(knn_resultpred2)

i=3
for(i in 3:nrow(X2_train)) {
  knn_mod2 = knn.reg(train = X2_train, test = X2_test, y = y2_train, k=i)
  ypred_knn2 = knn_mod2$pred
  knn_resultpred2 = cbind(knn_resultpred2,ypred_knn2)
}

vector_2 = c("N",3:233)
vector_2 = sub("^", "K", vector_2)
colnames(knn_resultpred2) <- vector_2

knn_resultrsme2 = data.frame(K=c(),rsme=c())
i=3
for(i in 3:nrow(X2_train)) {
  knn_mod2 = knn.reg(train = X2_train, test = X2_test, y = y2_train, k=i)
  ypred_knn2 = knn_mod2$pred
  rsme_knn2 = rsme(y2_test, ypred_knn2) 
  knn_resultrsme2 =  rbind(knn_resultrsme2, c(i,rsme_knn2))
}

names(knn_resultrsme2) = c("K", "rsme")
k_min2 = with(knn_resultrsme2, K[rsme == min(rsme)])

ggplot(data = knn_resultrsme2) + 
  geom_point(mapping = aes(x = K, y = rsme), color='lightgrey') + 
  theme_bw(base_size=18) +
  geom_vline(xintercept = k_min2, color = "purple", size=1) +
  labs(title = "RSME vs K for SClass65AMG") +
  theme(plot.title = element_text(hjust = 0.5))

knn_min2 = knn.reg(train = X2_train, test = X2_test, y = y2_train, k=k_min2)
ypred_knn2 = as.data.frame(knn_min2$pred)
names(ypred_knn2) = c("ypred_knn2")

E_test = arrange(E_test, mileage)
ypred_knn2 = mutate(ypred_knn2, mileage = E_test$mileage)
ypred_knn2 = mutate(ypred_knn2, price = E_test$price)
ypred_knn2 = mutate(ypred_knn2, ypred_knn3 = knn_resultpred2$K3)
ypred_knn2 = mutate(ypred_knn2, ypred_knn75 = knn_resultpred2$K75)
ypred_knn2 = mutate(ypred_knn2, ypred_lm = ypred_lm22)

ggplot(data = ypred_knn2) + 
  geom_point(mapping = aes(x = mileage, y = price), color='lightgrey') + 
  theme_bw(base_size=18) +
  geom_path(aes(x = mileage, y = ypred_knn2, color='KNN Min'), size=1.5) +
  geom_path(aes(x = mileage, y = ypred_knn3, color='KNN 3')) +
  geom_path(aes(x = mileage, y = ypred_knn75, color='KNN 75')) +
  geom_path(aes(x = mileage, y = ypred_lm, color='Linear Model')) +
  scale_color_discrete(name = "Models")+
  labs(title = "Multiple price prediction for SClass65AMG") +
  theme(plot.title = element_text(hjust = 0.5))
