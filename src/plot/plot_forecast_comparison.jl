"""
```
plot_forecast_comparison(var, histold, fcastold, histnew, fcastnew;
    output_file = "", start_date = Nullable{Date}(),
    end_date = Nullable{Date}(), bandpcts::Vector{String} = [\"90.0%\"],
    hist_label = \"History\", old_fcast_label = \"Old Forecast\",
    new_fcast_label = \"New Forecast\", hist_color = :black,
    old_fcast_color = :blue, new_fcast_color = :red, tick_size = 2,
    legend = :best)

plot_forecast_comparison(m_old, m_new, var, class, input_type, cond_type;
    forecast_string = "", bdd_and_unbdd = false, kwargs...)
```

### Inputs

- `var::Symbol`: e.g. `:obs_gdp`

**Method 1 only:**

- `histold::MeansBands`
- `fcastold::MeansBands`
- `histnew::MeansBands`
- `fcastnew::MeansBands`

**Method 2 only:**

- `m_old::AbstractModel`
- `m_new::AbstractModel`
- `class::Symbol`
- `input_type::Symbol`
- `output_type::Symbol`

### Keyword Arguments

- `output_file::String`: if specified, plot will be saved there as a PDF
- `start_date::Nullable{Date}`
- `end_date::Nullable{Date}`
- `bandpcts::Vector{String}`: which bands to plot
- `hist_label::String`
- `old_fcast_label::String`
- `new_fcast_label::String`
- `hist_color::Colorant`
- `old_fcast_color::Colorant`
- `new_fcast_color::Colorant`
- `tick_size::Int`: x-axis (time) tick size in units of years
- `legend`

**Method 2 only:**

- `forecast_string::String`
- `bdd_and_unbdd::Bool`: if true, then unbounded means and bounded bands are plotted

### Output

- `p::Plot`
"""
function plot_forecast_comparison(m_old::AbstractModel, m_new::AbstractModel,
                                  var::Symbol, class::Symbol,
                                  input_type::Symbol, cond_type::Symbol;
                                  forecast_string::String = "",
                                  bdd_and_unbdd::Bool = false,
                                  title = "",
                                  kwargs...)
    # Read in MeansBands
    histold  = read_mb(m_old, input_type, cond_type, Symbol(:hist, class),
                       forecast_string = forecast_string)
    fcastold = read_mb(m_old, input_type, cond_type, Symbol(:forecast, class),
                       forecast_string = forecast_string, bdd_and_unbdd = bdd_and_unbdd)
    histnew  = read_mb(m_new, input_type, cond_type, Symbol(:hist, class),
                       forecast_string = forecast_string)
    fcastnew = read_mb(m_new, input_type, cond_type, Symbol(:forecast, class),
                       forecast_string = forecast_string, bdd_and_unbdd = bdd_and_unbdd)

    # Get title if not provided
    if isempty(title)
        title = describe_series(m_new, var, class)
    end

    plot_forecast_comparison(var, histold, fcastold, histnew, fcastnew;
                             title = title, kwargs...)
end

function plot_forecast_comparison(var::Symbol,
                                  histold::MeansBands, fcastold::MeansBands,
                                  histnew::MeansBands, fcastnew::MeansBands;
                                  output_file::String = "",
                                  start_date::Nullable{Date} = Nullable{Date}(),
                                  end_date::Nullable{Date} = Nullable{Date}(),
                                  bandpcts::Vector{String} = ["90.0%"],
                                  title::String = "",
                                  old_hist_label::String = "",
                                  old_fcast_label::String = "Old Forecast",
                                  new_hist_label::String = "",
                                  new_fcast_label::String = "New Forecast",
                                  old_hist_color::Colorant = parse(Colorant, :grey),
                                  old_fcast_color::Colorant = parse(Colorant, :blue),
                                  new_hist_color::Colorant = parse(Colorant, :black),
                                  new_fcast_color::Colorant = parse(Colorant, :red),
                                  tick_size::Int = 2,
                                  legend = :best)

    # Initialize plot
    p = Plots.plot(legend = legend, title = title)

    # Set up common keyword arguments
    common_kwargs = Dict{Symbol, Any}()
    common_kwargs[:start_date]  = start_date
    common_kwargs[:end_date]    = end_date
    common_kwargs[:bands_pcts]  = bandpcts
    common_kwargs[:bands_style] = :line
    common_kwargs[:tick_size]   = tick_size
    common_kwargs[:legend]      = legend
    common_kwargs[:title]       = title

    # Plot old and new histories/forecasts separately
    p = plot_history_and_forecast(var, histold, fcastold; plot_handle = p,
                                  hist_label = old_hist_label, forecast_label = old_fcast_label,
                                  hist_color = old_hist_color, forecast_color = old_fcast_color,
                                  bands_color = old_fcast_color, linestyle = :solid,
                                  common_kwargs...)
    p = plot_history_and_forecast(var, histnew, fcastnew; plot_handle = p,
                                  hist_label = new_hist_label, forecast_label = new_fcast_label,
                                  hist_color = new_hist_color, forecast_color = new_fcast_color,
                                  bands_color = new_fcast_color, linestyle = :dash,
                                  common_kwargs...)

    # Save if output_file provided
    save_plot(p, output_file)

    return p
end