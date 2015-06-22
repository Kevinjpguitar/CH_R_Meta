#Ū���
dta <- read.table('http://myweb.ncku.edu.tw/~cpcheng/Rbook/12/data/Addiction.txt', header = T)

#��i�ǮզѮv�i�H�[��ܶ�
dta <- dta[, 1:8]

#��ܫe�����A�ݸ�Ƶ��c
#�{������12.1
head(dta)
str(dta)

#�{������12.2
summary(dta)

#�{������12.3
#�p��C���ܶ��U���Ǧ���
t(apply(dta,  2, table))

#�p��C���ܶ��U���Ǧʤ���
show(dtap <- prop.table(t(apply(dta,  2, table)), 1))

#���Jlattice�M��A�ǳƵe��
require(lattice)

#ø�s�U�ܶ��ʤ���
#��12.1
dotplot(dtap[order(dtap[, 1]), ], pch = c(1, 20), grid = T,
  ylab = '�ܶ�', xlab = '�U�ܶ������O�����ʤ���',
  auto.key = list(column = 2, pch=c(1,20),text = c('�C_�k_�_', '��_�k_�O')))


#�{������12.4
#�ݬݦ��}�P�ʧO�����Y
with(dta, table(���}, �ʧO))

#������v
with(dta, prop.table(table(���}, �ʧO), 2))

#�˩w
with(dta, chisq.test(table(���}, �ʧO)))

#�⦨�}�P��L�ܶ��d���˩w p ��
with(dta, sapply(2:8, function(x){ c(names(dta[, 2:8])[x-1],
   round(chisq.test(table(dta[, 1], dta[, x]))$p.val, 6))}))

#�p��C���ܶ��U���O�����}�B�����}��v
dta_p <- with(dta, sapply(2:8, function(x){
              prop.table(table(dta[, x], dta[, 1]), 1) } ))
              
#�u�����}��v
dta_p <- t( dta_p[3:4, ])

#��i�ܶ��W��
rownames(dta_p) <- names(dta[, -1])
 
#�H�ܶ����U���O���}��v�t���]�ĪG�q�^�A�ƦC�ܶ�
d_p <- dta_p[order(abs(dta_p[, 1] - dta_p[, 2])), ]

#���J reshape �M��A���ܸ�ƱƦC
require(reshape2)
d_p <- melt(d_p)

#�R�W�T�����A�ݤ@�U���
names(d_p) <- c('�ܶ�', '���O', '��v')
#�{������12.5
d_p

#�e��
#��12.2
dotplot(�ܶ� ~ ��v, data = d_p,  xlim = c(.1, .9),
  xlab = '��v', ylab = '�ܶ�', main = '���P���O���}��v',
  panel = function(x, y){
    panel.xyplot(x, y, pch = 16)
    panel.abline(v = .5, col = 8, lty = 2)
    panel.segments(d_p[d_p$���O == 2, '��v'], as.numeric(y), 
                   d_p[d_p$���O == 1, '��v'], as.numeric(y), lty = 3)
   }) 




#���Ʀ��}�ܶ��A�T�{�����쪺���ҡ]�O�^�Ʀb�᭱
dta$���} <- ordered(dta$���}, levels = c('�_', '�O'))

#�N��Ƥ���b�A�@�ӥΨӰV�m�A�@�ӥΨӴ���
set.seed(20150214)
n <- dim(dta)[1]
nh <- sample(1:n, floor(n/2))
dta_trn <- dta[nh, ] 
dta_tst <- dta[-nh, ]

#���J rpart �M��
library(rpart)

#�M������R will all the variables as predictors
#�{������12.6, 12.7
summary(rslt_trn <- rpart(���} ~ ., data = dta_trn, 
           control = rpart.control(cp = .001, minsplit = 50, minbucket = 20) ) )

#���Jrpart.plot�M��
library(rpart.plot) 

#�⵲�G�e�X�Ӥ���M��
#��12.3
prp(rslt_trn, type = 2, extra = 7, left = F, nn = T)



#�հŨM����A�ϥܸ��r��X
#�{������12.8
printcp(rslt_trn)
#��12.4
plotcp(rslt_trn)
 
#�ŤF�A�õe�X��
#��12.5
show(rslt_trn_p <- prune(rslt_trn, cp = .0045))
prp(rslt_trn_p, type = 2, extra = 7, left = F, nn = T)



#�椬���ҡC�����Ӽ˥��A���P�װŮɥ��T�v
trn_cp <- printcp(rslt_trn)[, 'CP']

# extract the dimension of cp to be used a lot later
n_cp <- length(trn_cp) - 1

pc <- matrix(NA, nrow = n_cp, ncol = 3)

for ( i in 1:n_cp ) {
  pc[i, 1]  <- (trn_cp[i] + trn_cp[i+1]) / 2
  rslt_trn_p <- prune(rslt_trn, cp = pc[i, 1])
  t0 <- table(dta_trn$���}, predict(rslt_trn_p, newdata = dta_trn, type = 'class'))
  pc[i, 2] <- (t0[1, 1] + t0[2, 2])/ sum(t0)
  t0 <- table(dta_tst$���}, predict(rslt_trn_p, newdata = dta_tst, type = 'class'))
  pc[i, 3] <- (t0[1, 1] + t0[2, 2])/sum(t0)
}

#�ݵ��G
#�{������12.9
colnames(pc) <- c('CP', '�V�m�˥����T�v', '���ռ˥����T�v')
print(pc <- round(pc, 4))

#�e�� 
#��12.6
plot(x = 1:n_cp, y = pc[, 2], xlab = '�����ʰѼƭ�', ylab = '�������T�v', type = 'p', 
     axes = FALSE, ylim = range(pc[, -1]) + IQR(pc[, -1]) * c(-1.5, 1.5))
points(x = 1:n_cp, y = pc[, 3], pch = 16)
axis(1, at = 1:n_cp, labels = pc[, 1])
axis(2)
axis(4)
grid()
legend('topleft', legend = c('�V�m', '����'), pch = c(1, 16), bty = 'n') 
box() 
###