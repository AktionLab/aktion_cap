module AktionCap
  class Railtie < Rails::Railtie
    railtie_name :aktion_cap

    rake_tasks do
      require 'aktion_cap/tasks'
    end
  end
end

