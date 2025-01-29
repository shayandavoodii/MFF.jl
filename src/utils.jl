const properties = ("timestamp", "open", "high", "low", "close", "adjclose", "vol")
function plot_data end

function check_prprty(val, prprty)
  isequal(val, nothing) && error(
    """property ($prprty) is not valid or doesn't exist. Valid properties are:
    \"timestamp", \"open", \"high", \"low", \"close", \"adjclose", \"vol". """
  )
end
