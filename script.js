const languageButton = document.querySelector('.language-toggle');
const translations = {
  zh: {
    navAbout: '关于', navProjects: '探索', navContact: '联系',
    heroTitle: '在学习中探索。<br><span>在实践中成长。</span>',
    heroIntro: '你好，我是 Ye Hongyu，一名学生。这里记录我的学习、经历与持续探索的事情。',
    viewProjects: '查看探索', contactMe: '联系我', photoPlaceholder: '个人照片即将更新',
    aboutTitle: '关于我', aboutLead: '我是一名保持好奇、乐于学习和探索新事物的学生。',
    aboutDetail: '目前我正在积累知识与实践经验。这个网站会持续记录我的成长、想法和未来完成的项目。',
    skill1: '持续学习', skill2: '独立思考', skill3: '探索实践', skill4: '开放合作',
    projectsTitle: '学习与探索', projectType1: '个人成长', projectTitle1: '学习记录',
    projectDesc1: '未来将在这里分享课程学习、读书笔记和实践成果。', projectType2: '项目实践',
    projectTitle2: '未来项目', projectDesc2: '完成新的个人或团队项目后，我会在这里记录过程与收获。',
    projectType3: '兴趣探索', projectTitle3: '想法与发现', projectDesc3: '这里将收录我感兴趣的主题、文章以及生活中的新发现。',
    comingSoon: '持续更新中', contactTitle: '欢迎与我联系。',
    contactText: '如果你想交流学习、兴趣或合作想法，可以通过邮件或 GitHub 找到我。', backToTop: '回到顶部 ↑'
  },
  en: {
    navAbout: 'About', navProjects: 'Explore', navContact: 'Contact',
    heroTitle: 'Explore through learning.<br><span>Grow through practice.</span>',
    heroIntro: "Hi, I'm Ye Hongyu, a student documenting what I learn, experience, and explore.",
    viewProjects: 'View exploration', contactMe: 'Contact me', photoPlaceholder: 'Photo coming soon',
    aboutTitle: 'About me', aboutLead: "I'm a curious student who enjoys learning and exploring new things.",
    aboutDetail: "I'm currently building knowledge and practical experience. This site will document my growth, ideas, and future projects.",
    skill1: 'Continuous learning', skill2: 'Independent thinking', skill3: 'Hands-on exploration', skill4: 'Open collaboration',
    projectsTitle: 'Learning & exploration', projectType1: 'Personal growth', projectTitle1: 'Learning journal',
    projectDesc1: 'I will share coursework, reading notes, and practical outcomes here.', projectType2: 'Project practice',
    projectTitle2: 'Future projects', projectDesc2: 'New personal and team projects will be documented here with their process and lessons.',
    projectType3: 'Interests', projectTitle3: 'Ideas & discoveries', projectDesc3: 'A place for topics, writing, and discoveries that interest me.',
    comingSoon: 'Coming soon', contactTitle: "Let's connect.",
    contactText: 'Reach out by email or GitHub to talk about learning, shared interests, or collaboration.', backToTop: 'Back to top ↑'
  }
};

function setLanguage(language) {
  document.documentElement.lang = language === 'zh' ? 'zh-CN' : 'en';
  document.querySelectorAll('[data-i18n]').forEach((element) => {
    const value = translations[language][element.dataset.i18n];
    if (value) element.innerHTML = value;
  });
  languageButton.textContent = language === 'zh' ? 'EN' : '中';
  localStorage.setItem('language', language);
}

setLanguage(localStorage.getItem('language') || 'zh');
languageButton.addEventListener('click', () => {
  setLanguage(document.documentElement.lang.startsWith('zh') ? 'en' : 'zh');
});

document.getElementById('year').textContent = new Date().getFullYear();

const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12 });

document.querySelectorAll('.reveal').forEach((element) => observer.observe(element));
