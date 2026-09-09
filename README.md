# Predicting Wine Quality from Physicochemical Properties: A Model Comparison

## Introduction
This project analyzed whether physicochemical properties of wine can be used to predict wine quality scores, using three modeling approaches - linear regression, regression trees, and random forests.

The main goal is to measure how strongly these chemical variables relate to quality and how accurately they can predict quality scores.       

## Data Set
The dataset comprises two related files concerning red and white Portuguese “Vinho Verde” wines from northern Portugal. 

**11 physicochemical input variables:**
1. fixed acidity
2. volatile acidity
3. citric acid
4. residual sugar
5. chlorides
6. free sulfur dioxide
7. total sulfur dioxide
8. density
9. pH
10. sulphates
11. alcohol

**1 output variable:**
1. quality (score from 0 - 10) 

Dataset from [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/186/wine+quality)

## Tools
Rstudio - View [R scripts](Predicting_wine_quality.R)

## Exploratory Data Analysis
Before building the different models, I explored the datasets to understand the general distributions and variability for each of their variables. 

#### Summary Statistics 
<img width="753" height="402" alt="image" src="https://github.com/user-attachments/assets/2d500906-6343-4ef4-b3a4-6048a1f97052" />

Looking at the summary statistics, white wine has a notably higher residual sugar level (6.39) compared to red wine (2.54), and also higher total sulfur dioxide levels (138.4 vs 46.47).

#### Correlation Heatmap  
<img width="765" height="363" alt="image" src="https://github.com/user-attachments/assets/06f79c84-975f-4eee-b62b-0159c3568664" />

The white wine correlation heatmap (left) reveals that alcohol has the strongest positive correlation (+0.6), and density has the lowest correlation (-0.4) with quality, suggesting white wines with higher alcohol and lower density are more likely to receive higher scores. Similarly, the red wine heatmap (right), reveals strong positive correlation with alcohol and the lowest correlation with volatile acidity (-0.6). 	

## Modeling Approaches 
### Linear Regression
#### Benchmark Model
As a first pass, I fit a benchmark linear regression model for both white and red wine using all 11 physicochemical predictors. Both models were statistically significant, explaining ~28% of quality variation in white wine (R² = 0.28) and ~36% in red wine (R² = 0.36), with alcohol, volatile acidity, and sulphates significant predictors in both.

| | White Wine | Red Wine |
|---|---|---|
| In-Sample MSE | 0.6103 | 0.4236 |
| Out-of-Sample MSE | 0.5941 | 0.3906 |
| Adjusted R² | 0.2985 | 0.3480 |

While the benchmark models confirmed that chemical predictors have a statistically significant relationship with quality, the relatively low R² values suggested that a simple linear model wasn't enough to fully capture the relationship — motivating a more refined variable selection step.

#### Best Subsets Selection
Using best subsets variable selection (via BIC), I simplified each benchmark model down to its strongest predictors:

- **White wine:** selected 7 predictors (fixed acidity, volatile acidity, residual sugar, free sulfur dioxide, density, pH, sulphates) — adjusted R² = 0.299, 5-fold CV MSE = 0.574
- **Red wine:** selected 6 predictors (volatile acidity, chlorides, total sulfur dioxide, pH, sulphates, alcohol) — adjusted R² = 0.347, 5-fold CV MSE = 0.424

The red wine model outperformed the white wine model on both prediction error and adjusted R².

#### Residual Diagnostics
Residual diagnostic plots showed that linear regression was a useful benchmark but not the best fit for the data. Residuals-vs-fitted plots showed non-random patterns, suggesting the relationship between predictors and quality isn't fully linear, and Q-Q plots — especially for white wine — showed departures from normality in the tails. This motivated moving to more flexible, non-linear methods.

### Regression Trees
Regression trees relax the linearity assumption by recursively splitting the data into groups based on predictor thresholds, assigning each group a predicted quality score.
<img width="603" height="465" alt="image" src="https://github.com/user-attachments/assets/8a9532d3-be83-43c3-9a62-0f4875ba0e79" />

- **White wine (left):** in-sample MSE = 0.596, out-of-sample MSE = 0.574. Alcohol was the first (most important) split; predicted scores ranged from 4.78 (low alcohol, high volatile acidity) to 6.82 (high alcohol, moderate free sulfur dioxide)
- **Red wine (right) :** in-sample MSE = 0.400, out-of-sample MSE = 0.418. Alcohol was again the top split, followed by sulphates, volatile acidity, and pH; predicted scores ranged from 4.00 to 6.86

Regression trees slightly outperformed linear regression on out-of-sample error for both wines and offered more interpretable decision rules, but were ultimately surpassed by random forests.

### Random Forests
Random forests build many regression trees on bootstrapped samples and average their predictions, reducing overfitting and capturing non-linear interactions. 
<img width="758" height="263" alt="image" src="https://github.com/user-attachments/assets/befccc9a-31d1-4342-b560-372e09c080d4" />

- **White wine:** out-of-sample MSE = 0.534 — the lowest among all three methods for this dataset
- **Red wine:** out-of-sample MSE = 0.277 — the lowest overall across both datasets and all methods

Error plots showed prediction error dropping sharply as trees were added, then stabilizing near 500 trees. Variable importance plots identified **alcohol** as the top predictor for both wines; **density** and **free sulfur dioxide** were moderately important for white wine, while **sulphates** and **volatile acidity** were the next most important for red wine. Random forests had the best predictive accuracy overall, at the cost of interpretability compared to a single tree.
<img width="758" height="275" alt="image" src="https://github.com/user-attachments/assets/bc065ee7-a0ec-4faf-8f86-afaea9983e45" />

## Results Comparison - Final Model Selection

| Method (White Wine) | In-Sample MSE | Out-of-Sample MSE |
|---|---|---|
| Benchmark Linear Regression | 0.6103 | 0.5941 |
| Best Subsets Linear Regression | 0.6101 | 0.5741 (5-fold CV) |
| Regression Tree | 0.5956 | 0.5743 |
| Random Forest | 0.4439 | 0.5337 |

| Method (Red Wine) | In-Sample MSE | Out-of-Sample MSE |
|---|---|---|
| Benchmark Linear Regression | 0.4236 | 0.3906 |
| Best Subsets Linear Regression | 0.4239 | 0.4243 (5-fold CV) |
| Regression Tree | 0.4006 | 0.4175 |
| Random Forest | 0.3308 | 0.2774 |

Random forest produced the lowest out-of-sample MSE for both wine types — 0.534 for white wine and 0.277 for red wine — outperforming both linear regression and regression trees. The improvement was more pronounced for red wine, where random forest cut out-of-sample error by roughly 29% relative to the best subsets linear model, compared to a ~7% reduction for white wine.

**Final model selected: Random Forest**, for both red and white wine, based on lowest out-of-sample prediction error.

## Key Insights 
- **Non-linearity matters more for red wine than white wine.** Random forest's error reduction over linear regression was roughly 5x larger for red wine, implying red wine quality is driven by more complex predictor interactions rather than simple additive effects.
- **Alcohol is the single most consistent predictor of quality**, appearing as the top-ranked variable importance factor in random forests and the first splitting variable in both regression trees, across both wine types.
- **There's a real interpretability-accuracy tradeoff.** Regression trees gave clear, explainable decision rules (e.g., "alcohol < 10.53 → lower predicted quality") at a small accuracy cost relative to random forest, which is more accurate but functions as a black box.
- **Chemical predictors alone leave substantial variation unexplained** — even the best model (random forest) has meaningful residual error, consistent with the dataset's exclusion of non-chemical factors like grape variety, brand, and price. 
