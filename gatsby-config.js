module.exports = {
  plugins: [
    {
      resolve: `gatsby-theme-blog`,
      options: {},
    },
    {
      resolve: 'gatsby-plugin-emoji-favicon',
      options: {
        emoji: '🌊'
      }
    }
  ],
  // Customize your site metadata:
  siteMetadata: {
    title: `Makon Cline`,
    author: `Makon Cline`,
    description: `This is my personal site where I drop notes and articles about things that I am interested in.`,
    social: [
      {
        name: `twitter`,
        url: `https://twitter.com/MakonCline`,
      },
      {
        name: `github`,
        url: `https://github.com/makoncline`,
      },
    ],
  },
}
