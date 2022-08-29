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
        'avatar-ss': "url('/images/avatar_ss.png')",
        'avatar-soup-os': "url('/images/avatar_soup_os.png')",
        'id-card-icon': "url('/images/id_card_icon.png')",
        'entangle-icon': "url('/images/entangle_icon.png')",
        'agi-icon': "url('/images/agi_icon.png')",
        'soup-os-bg-1': "url('/images/soup_os_bg_1.png')",
        'soup-os-bg-2': "url('/images/soup_os_bg_2.png')",
        'soup-os-bg-3': "url('/images/soup_os_bg_3.png')",
        'soup-os-bg-4': "url('/images/soup_os_bg_4.png')",
          
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
