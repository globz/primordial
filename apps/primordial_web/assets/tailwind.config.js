/** @type {import('tailwindcss').Config} */ 
module.exports = {
  content: [
      './js/**/*.js',
      '../lib/*_web.ex',
      '../lib/*_web/**/*.*ex',
  ],
  theme: {
    screens: {
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',
    },
    fontFamily: {
      sans: ['monospace', 'sans-serif'],
      serif: ['Merriweather', 'serif'],
    },
    extend: {
      spacing: {
        '128': '32rem',
        '144': '36rem',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      backgroundImage: {
        'avatar-ss': "url('/images/avatars/avatar_ss.webp')",
        'avatar-soup-os': "url('/images/avatars/avatar_soup_os.webp')",
        'id-card-icon': "url('/images/soup/icons/id_card_icon.webp')",
        'entangle-icon': "url('/images/soup/icons/entangle_icon.webp')",
        'agi-icon': "url('/images/soup/icons/agi_icon.webp')",
        'simulation-icon': "url('/images/soup/icons/simulation_icon.webp')",
        'jobs-icon': "url('/images/soup/icons/jobs_icon.webp')",
        'profession-icon': "url('/images/soup/icons/profession_icon.webp')",
        'system-state-icon': "url('/images/soup/icons/system_state_icon.webp')",
        'democratic-results-icon': "url('/images/soup/icons/democratic_results_icon.webp')",
        'soup-os-bg-1': "url('/images/soup/bg/soup_os_bg_1.webp')",
        'soup-os-bg-2': "url('/images/soup/bg/soup_os_bg_2.webp')",
        'soup-os-bg-3': "url('/images/soup/bg/soup_os_bg_3.webp')",
        'soup-os-bg-4': "url('/images/soup/bg/soup_os_bg_4.webp')",
          
      }
    },
    variants: {
        extend: {
            visibility: ["group-hover"],
        },
    },
  },
  plugins: [],
}
