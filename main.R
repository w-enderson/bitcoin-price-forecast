library(tidyquant)
library(dplyr)
library(ggplot2)
library(plotly)
library(prophet)
library(fpp3)


# pegando dados
data <- tq_get("BTC-USD", from="2021-01-01") 

# ajustando os dados
df <- data |>
    select(date, adjusted) |>
    rename(ds=date, y=adjusted) |>
    as_tsibble(index=ds)

# observando o comportamento dos dados (anual, mensal, semanal)
gg_season(df, y, period="year") -> plt1
gg_season(df, y, period="month") -> plt2
gg_season(df, y, period="week") -> plt3


# criando modelo 
model <- prophet(df)

# previsao de 1 ano
future <- make_future_dataframe(model, periods= 365)
forecast <- predict(model, future)


# gráfico preço x tempo
plot(df[["ds"]], df[["y"]], type="l")

# Gráfico do forecast
plot(model, forecast) -> plt4

# Componentes adicionais do modelo
prophet_plot_components(model, forecast) -> plt5


# gráfico interativo
plot_forecast <- plot_ly() %>%
    add_lines(x= forecast$ds, y= forecast$yhat, name= "Previsão", line= list(color= "blue")) %>%
    add_ribbons(
        x= forecast$ds,
        ymin= forecast$yhat_lower,
        ymax= forecast$yhat_upper,
        name= "Intervalo de confiança",
        line= list(color= "rgba(0, 0, 255, 0)"),
        fillcolor= "rgba(0, 0, 255, 0.2)"
    ) %>%
    add_lines(x= df$ds, y= df$y, name= "Dados reais", line= list(color= "black")) %>%
    layout(
        title= "Forecast do Bitcoin (BTC-USD)",
        xaxis= list(title= "Data"),
        yaxis= list(title= "Preço"),
        hovermode= "x"
    )

print(plot_forecast)

