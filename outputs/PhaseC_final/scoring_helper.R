function (new_df) 
{
    items_order <- rownames(coef(mod, simplify = TRUE)$items)
    to_num <- function(x) {
        if (is.factor(x)) 
            as.numeric(as.character(x))
        else if (inherits(x, "haven_labelled")) 
            as.numeric(as.character(haven::as_factor(x)))
        else as.numeric(x)
    }
    X <- as.data.frame(lapply(new_df[, items_order, drop = FALSE], 
        to_num))
    out <- fscores(mod, method = "EAP", full.scores.SE = TRUE, 
        response.pattern = X)
    data.frame(theta = out[, "F1"], se = out[, "SE_F1"])
}
