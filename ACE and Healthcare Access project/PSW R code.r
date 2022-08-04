library(haven)
library(survey)
library(tidyverse)
library(drgee)

sheet3 <- read_sas("C:/Users/VANCOLNE/Desktop/NSCH/data/1718/sheet3.sas7bdat", NULL)

sheet3<- as.data.frame(sheet3)

treatment<-sheet3$Insurance_1718

t.model <- glm(treatment ~ PrntNativity_1718+HHLanguage_1718+famstruct5_1718+AdultEduc_1718+FamResilience_1718+povlev4_1718+fwc_1718, data=sheet3, family=binomial)

pscore <- predict(t.model, data=sheet3, type="response")

sheet3$ate.wt <- ifelse(treatment==1, 1/pscore, 1/(1-pscore))

sheet3$comb.ate <- sheet3$ate.wt*sheet3$fwc_1718

Ins<-sheet3 %>%
  filter(is.na(comb.ate)==FALSE)

write.csv(Ins,col.names = TRUE, file="C:/Users/VANCOLNE/Desktop/NSCH/data/1718/sheet3modi.csv",na="")



treatment2<-sheet3$MedHome_1718

t.model2 <- glm(treatment2 ~  race4_1718+InsType_1718+fwc_1718, data=sheet3, family=binomial)

pscore2 <- predict(t.model2, data=sheet3, type="response")

sheet3$ate.wt2 <- ifelse(treatment2==1, 1/pscore2, 1/(1-pscore2))

sheet3$comb.ate2 <- sheet3$ate.wt2*sheet3$fwc_1718

Med<-sheet3 %>%
  filter(is.na(comb.ate2)==FALSE)

write.csv(Med,col.names = TRUE, file="C:/Users/VANCOLNE/Desktop/NSCH/data/1718/sheet3modi2.csv",na="")





# Set up survey design with strata and combined weights
comb.ate.design <- svydesign(ids=~1, strata=Ins$FIPSST, weights=Ins$comb.ate, data=Ins)


#PPSW logistic regression
lm.comb <- svyglm(ACE ~ Insurance_1718 + SC_AGE_YEARS + sex_1718 + factor(race4_1718) + factor(famstruct5_1718) + 
                    factor(FamResilience_1718) + HHLanguage_1718 + factor(PrntNativity_1718) + factor(povlev4_1718), 
                  design=comb.ate.design, family=quasibinomial(link="logit"))
confint(lm.comb, parm=c("Insurance_1718"))
summary(lm.comb)


# DR Estimation
fit <- drgee(oformula=ACE~SC_AGE_YEARS + sex_1718 + race4_1718 + famstruct5_1718 + FamResilience_1718 + HHLanguage_1718 + PrntNativity_1718 + povlev4_1718,
             eformula=Insurance_1718~SC_AGE_YEARS + sex_1718 + race4_1718 + famstruct5_1718 + FamResilience_1718 + HHLanguage_1718 + PrntNativity_1718 + povlev4_1718,
             iaformula=~ SC_AGE_YEARS + sex_1718 + race4_1718 + famstruct5_1718 + FamResilience_1718 + HHLanguage_1718 + PrntNativity_1718 + povlev4_1718, olink="log", 
             elink="logit", estimation.method="dr", data=Ins)

summary(fit)

# univariate log binimial regression

unidesign <- svydesign(ids=~1, strata=Ins$FIPSST, weights=Ins$fwc_1718, data=Ins)

model<- svyglm(ACE ~ povlev4_1718, data=Ins, family=quasibinomial(link="log"),design=unidesign)

summary(model)



