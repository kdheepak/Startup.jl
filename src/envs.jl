@static if Sys.iswindows()

  ENV["EDITOR"] = "code"
  if Sys.iswindows()
    ENV["JULIA_EDITOR"] = "code.cmd -g"
  else
    ENV["JULIA_EDITOR"] = "code"
  end

end
