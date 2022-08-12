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
      }        
    }
  },
  plugins: [],
}
