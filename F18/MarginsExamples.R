## Margins Examples adapted from Robert Williams
## https://www3.nd.edu/~rwilliam/stats/Margins01.pdf
##
## Computing content: Methods for the glm class
## Statistical content: Adjusted precitions & marginal effects
##
## Updated: August 28, 2018
## To Do: Examples showing average adjusted predictions
#         Examples showing marginal effects
#         
# libraries: ------------------------------------------------------------------
library(tidyverse)

# directory (modify to reflect your own folder):  -----------------------------
path = '~/Stats506/F18/'

# NHANES data exported from Stata: --------------------------------------------
file = sprintf('%s/nhanes2f.csv', path)

nhanes2f = read_delim(file, delim = ',')

# Remove 2 missing values: ------------------------------------------------------
nhanes2f = nhanes2f %>% 
  filter( !is.na(diabetes) & !is.na(black) & !is.na(female) & !is.na(age) )


# Model 1: Basic Model: -------------------------------------------------------
mod1 = glm( diabetes ~ black + female + age, 
            family = binomial(link='logit'), data = nhanes2f)

summary(mod1)

# Adjusted (age = 20 or 70) predictions at the mean: --------------------------

# Mean values for each of our three variables
df_means = nhanes2f %>%
  summarize( black = mean( black ),
             female = mean( female ),
             age = mean(age)
            )

# New data frame for cases we want to predict
df_ap_age =
  with( df_means, tibble( age = c(20, 70), black = black, female = female ) )

# Use the predict method
ap_age = predict(mod1, df_ap_age, type = 'response')
names(ap_age) = df_ap_age$age

sprintf('%2.0f%%', 100*ap_age)

# Request std error
ap_age_se = predict(mod1, df_ap_age, type = 'response', se.fit=TRUE)
with(ap_age_se,
     {
     u = fit + 1.96*se.fit
     l = fit - 1.96*se.fit
     sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*fit, 100*l, 100*u)
     }
)

# Could also show use of confint here

# Could also break down delta method

# Model 2 - Age + Age^2: ------------------------------------------------------
nhanes2f = nhanes2f %>% mutate( age2 = age^2)

mod2 = glm( diabetes ~ black + female + age + age2, 
            family = binomial(link='logit'), data = nhanes2f)
summary(mod2)


mod2_ap_age_se = predict(mod2, df_ap_age, type = 'response', se.fit=TRUE)
with(mod2_ap_age_se,
     {
       u = fit + 1.96*se.fit
       l = fit - 1.96*se.fit
       sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*fit, 100*l, 100*u)
     }
)

# Model 3 - interact sex and age: ---------------------------------------------
mod3 = glm( diabetes ~ black + female + age + age:female, 
            family = binomial(link='logit'), data = nhanes2f)

df_ap_fem = with(df_means,
                      tibble(
                        female = c(0, 1),
                        age = age,
                        black = black
                      ))

mod3_ap_fem_se = predict(mod3, df_ap_fem, type = 'response', se.fit=TRUE)
with(mod3_ap_fem_se,
     {
       u = fit + 1.96*se.fit
       l = fit - 1.96*se.fit
       ap = sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*fit, 100*l, 100*u)
       
       d = diff(fit)
       u = d + 1.96*sum(se.fit)
       l = d - 1.96*sum(se.fit)
       me = sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*d, 100*l, 100*u)
       list( adj_pred = ap, margins = me)
     }
)


# Model 4 - Age groups: ------------------------------------------------------
mod4 = glm( diabetes ~ black + female + agegrp,
            family = binomial(link='logit'), data = nhanes2f)
summary(mod4)

age_groups = unique(nhanes2f$agegrp)
age_groups = age_groups[c(3,6,2,1,4,5)]

df_ap_agegrp = 
  with(df_means,
   tibble( agegrp = factor(age_groups, levels = age_groups),
           black = black,
           female = female
           ) 
  )

mod4_ap_agegrp = predict(mod4, df_ap_agegrp, type='response', se.fit=TRUE)
#broom::augment_columns(mod4, newdata = df_ap_agegrp, type='response', se.fit=TRUE)

with(mod4_ap_agegrp,
     {
       u = fit + 1.96*se.fit
       l = fit - 1.96*se.fit
       sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*fit, 100*l, 100*u)
     }
)

# Adjusted prediction at means (apm) above, show similarity to APR: -----------

df_ap_agegrp = 
  with(df_means,
       tibble( agegrp = factor(age_groups, levels = age_groups),
               black = 0,
               female = female
       ) %>% bind_rows(
         tibble( agegrp = factor(age_groups, levels = age_groups),
                 black = 1,
                 female = female
         )
       )
  )

mod4_ap_agegrpXblack = predict(mod4, df_ap_agegrp, type='response', se.fit=TRUE)
#broom::augment_columns(mod4, newdata = df_ap_agegrp, type='response', se.fit=TRUE)

mod4_ap_agegrpXblack_ci = 
  with(mod4_ap_agegrpXblack,
     {
       u = fit + 1.96*se.fit
       l = fit - 1.96*se.fit
       sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*fit, 100*l, 100*u)
     }
)

df_ap_agegrp %>% 
  mutate( `Prob (95% CI)` = mod4_ap_agegrpXblack_ci,
          black = ifelse( black == 1 , 'Black', 'Non-black' )
  ) %>%
  spread(black, `Prob (95% CI)`)


#! Make this a second lecture: -----------------------------------------------

# Let's create a function for computing adjusted predictions at the mean: -----
adjpred.lm = function( model, df_new ){
  pred = predict(model, df_new, type = 'response', se.fit = TRUE)
  with( predict(model, df_new, type = 'response', se.fit = TRUE) ,
      { u = fit + 1.96*se.fit
        l = fit - 1.96*se.fit
        ci = c(u, l)
      }
  ) 
  
}

#sprintf('%3.1f%% (95%% CI: %3.1f-%3.1f%%)', 100*fit, 100*l, 100*u)

## Note: getS3method('confint', 'glm', envir = asNamespace("MASS"))
##       getS3method('profile', 'glm', envir = asNamespace("MASS"))
##       getS3method('confint', 'profile.glm', envir = asNamespace("MASS"))
