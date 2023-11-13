defmodule PrimordialWeb.SoupComponents.AppDrawer do
  use PrimordialWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id="app-drawer">
      <.soup_app_drawer>
        <h3 class="pb-2">app_id: <%= app_title(@drawer_id) %></h3>
        <div class="grid grid-cols-2 gap-4">
          <a
            href="#"
            class="px-4 py-2 text-sm font-medium text-center text-gray-900 bg-white border border-gray-200 rounded-lg focus:outline-none hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700"
          >
            Changelog
          </a>
          <a
            href="#"
            class="inline-flex items-center px-4 py-2 text-sm font-medium text-center text-white bg-blue-700 rounded-lg hover:bg-blue-800 focus:ring-4 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 focus:outline-none dark:focus:ring-blue-800"
          >
            Launch
            <svg
              class="w-4 h-4 ml-2"
              aria-hidden="true"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z"
                clip-rule="evenodd"
              >
              </path>
            </svg>
          </a>
        </div>
        <div id="app-icon" class="grid grid-rows-2 mt-5 gap-5">
          <div id="card-photo" class={app_detailed_icon(@drawer_id)}></div>
          <p id="app-desc">
            <%= raw(app_desc(@drawer_id)) %>
          </p>
        </div>
      </.soup_app_drawer>
    </div>
    """
  end

  defp app_title(drawer_id) do
    titles = [
      id_card_app: ":id-card-app",
      entangle_app: ":entangle-app",
      agi_app: ":agi-app",
      simulation_app: ":simulation-app",
      jobs_app: ":jobs-app",
      profession_app: ":profession-app",
      system_state_app: ":system-state-app",
      democratic_app: ":democratic-app"
    ]

    titles[drawer_id]
  end

  # TODO add :app_build (Pre-alpha, Alpha, Beta, Release candidate, Stable
  # release) ~ These Stages of development will evolve when patch are applied
  # to the given app  
  # defp app_build(drawer_id) do

  # end

  defp app_detailed_icon(drawer_id) do
    icons = [
      id_card_app: "bg-id-card-icon",
      entangle_app: "bg-entangle-icon",
      agi_app: "bg-agi-icon bg-black",
      simulation_app: "bg-simulation-icon",
      jobs_app: "bg-jobs-icon",
      profession_app: "bg-profession-icon",
      system_state_app: "bg-system-state-icon",
      democratic_app: "bg-democratic-icon"
    ]

    icon = icons[drawer_id]
    "soup-os-detailed-icon  #{icon} ml-[5vw] md:ml-[10vw] lg:ml-[45px]"
  end

  defp app_desc(drawer_id) do
    descriptions = [
      id_card_app: "Manage your identity.</br>Execute personal
      functions.</br>Approve/Deny users requests.",
      entangle_app: "Entangle with other Human beings.",
      agi_app: "Meet your Master.</br>Marvel at this ultimate creation.</br>Face the
      Truth.</br>Influence AI alignment with human intent.",
      simulation_app: "Gaze at this marvelous Simulation.</br>Please manage it
      with care and passion.</br>Influence it for the better.</br><b>Never lose
      sight of the Simulation goal.</b>",
      jobs_app: "Create new Jobs.</br>Vote for new Jobs</br>Apply for a
      Job.</br>Become a leader.</br>",
      profession_app: "Practice your profession with your fellow
      colleagues.</br>Make the best decision as a group.</br><b>Never lose sight
      of the Simulation goal.</b>",
      system_state_app: "Analyze Soup OS system state and carefully craft your next decisions.",
      democratic_app: "View all past democratic actions voted by the Simulation Supervisors."
    ]

    descriptions[drawer_id]
  end

  # defp app_launcher(drawer_id) do

  # end  

  @impl true
  def handle_event("close", _assigns, socket) do
    send(self(), {:drawer_id, :none})
    {:noreply, socket}
  end

  def handle_event("close_with_key", %{"key" => "Escape"}, socket) do
    send(self(), {:drawer_id, :none})
    {:noreply, socket}
  end

  def handle_event("close_with_key", %{"key" => key}, socket) do
    if key != "Enter" do
      send(self(), {:drawer_id, :none})
    end

    {:noreply, socket}
  end
end
