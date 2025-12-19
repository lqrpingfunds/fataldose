// User Management System with LocalStorage
class UserManager {
    constructor() {
        this.currentUser = null;
        this.users = JSON.parse(localStorage.getItem('fatal_exe_users')) || [];
        this.init();
    }
    
    init() {
        // Check if user is already logged in
        const savedUser = localStorage.getItem('fatal_exe_current_user');
        if (savedUser) {
            this.currentUser = JSON.parse(savedUser);
        }
    }
    
    // User Registration
    register(firstName, lastName, email, password) {
        // Validate input
        if (!this.isValidEmail(email)) {
            return { success: false, message: 'Please enter a valid email address' };
        }
        
        if (password.length < 8) {
            return { success: false, message: 'Password must be at least 8 characters long' };
        }
        
        // Check if user already exists
        if (this.users.find(user => user.email === email)) {
            return { success: false, message: 'User with this email already exists' };
        }
        
        // Create new user
        const newUser = {
            id: this.generateId(),
            firstName,
            lastName,
            email,
            password: this.hashPassword(password),
            createdAt: new Date().toISOString(),
            lastLogin: null,
            role: 'student',
            
            // User stats
            stats: {
                completedLessons: 0,
                totalLessons: 6,
                averageScore: 0,
                learningHours: 0,
                achievements: 0,
                totalAchievements: 7,
                streakDays: 1,
                lastActiveDate: new Date().toISOString().split('T')[0],
                overallProgress: 0,
                
                // Lesson progress
                lessonProgress: {
                    1: { completed: false, progress: 0, lastAccessed: null },
                    2: { completed: false, progress: 0, lastAccessed: null },
                    3: { completed: false, progress: 0, lastAccessed: null },
                    4: { completed: false, progress: 0, lastAccessed: null },
                    5: { completed: false, progress: 0, lastAccessed: null },
                    6: { completed: false, progress: 0, lastAccessed: null }
                },
                
                // Test results
                testResults: [],
                
                // Achievements
                achievements: [],
                
                // Certificates
                certificates: []
            },
            
            // Settings
            settings: {
                theme: 'light',
                notifications: true,
                autoPlayVideos: true,
                showHints: true,
                language: 'en'
            }
        };
        
        // Add to users array
        this.users.push(newUser);
        
        // Save to localStorage
        this.saveUsers();
        
        return { success: true, user: newUser };
    }
    
    // User Login
    login(email, password) {
        const user = this.users.find(u => u.email === email);
        
        if (!user) {
            return { success: false, message: 'Invalid email or password' };
        }
        
        // In a real app, you would verify the hashed password
        // For demo purposes, we'll just check if it matches
        if (user.password !== this.hashPassword(password)) {
            return { success: false, message: 'Invalid email or password' };
        }
        
        // Update last login
        user.lastLogin = new Date().toISOString();
        
        // Update streak
        this.updateStreak(user);
        
        // Set as current user
        this.currentUser = user;
        
        // Save to localStorage
        this.saveCurrentUser();
        this.saveUsers();
        
        return { success: true, user };
    }
    
    // User Logout
    logout() {
        this.currentUser = null;
        localStorage.removeItem('fatal_exe_current_user');
    }
    
    // Update User Stats
    updateUserStats(userId, updates) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return false;
        
        Object.assign(user.stats, updates);
        this.saveUsers();
        
        // Update current user if it's the same
        if (this.currentUser && this.currentUser.id === userId) {
            Object.assign(this.currentUser.stats, updates);
            this.saveCurrentUser();
        }
        
        return true;
    }
    
    // Complete a Lesson
    completeLesson(userId, lessonId) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return false;
        
        const lesson = user.stats.lessonProgress[lessonId];
        if (!lesson) return false;
        
        // Mark as completed
        lesson.completed = true;
        lesson.progress = 100;
        lesson.completedAt = new Date().toISOString();
        
        // Update overall stats
        user.stats.completedLessons = Object.values(user.stats.lessonProgress)
            .filter(l => l.completed).length;
        
        user.stats.overallProgress = Math.round(
            (user.stats.completedLessons / user.stats.totalLessons) * 100
        );
        
        // Add learning hours
        user.stats.learningHours += 1;
        
        // Check for achievements
        this.checkAchievements(user);
        
        this.saveUsers();
        
        if (this.currentUser && this.currentUser.id === userId) {
            Object.assign(this.currentUser.stats, user.stats);
            this.saveCurrentUser();
        }
        
        return true;
    }
    
    // Add Test Result
    addTestResult(userId, testId, score, correctAnswers, totalQuestions, timeTaken) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return false;
        
        const result = {
            testId,
            score,
            correctAnswers,
            totalQuestions,
            timeTaken,
            date: new Date().toISOString()
        };
        
        user.stats.testResults.push(result);
        
        // Update average score
        const totalTests = user.stats.testResults.length;
        const totalScore = user.stats.testResults.reduce((sum, r) => sum + r.score, 0);
        user.stats.averageScore = Math.round(totalScore / totalTests);
        
        // Check for test achievements
        this.checkTestAchievements(user, result);
        
        this.saveUsers();
        
        if (this.currentUser && this.currentUser.id === userId) {
            Object.assign(this.currentUser.stats, user.stats);
            this.saveCurrentUser();
        }
        
        return true;
    }
    
    // Check and Award Achievements
    checkAchievements(user) {
        const achievements = [];
        
        // First lesson completed
        if (user.stats.completedLessons === 1 && !user.stats.achievements.includes('first_lesson')) {
            achievements.push({
                id: 'first_lesson',
                title: 'First Step',
                description: 'Completed your first cybersecurity lesson',
                icon: 'fa-star',
                date: new Date().toISOString()
            });
            user.stats.achievements.push('first_lesson');
        }
        
        // Three lessons completed
        if (user.stats.completedLessons === 3 && !user.stats.achievements.includes('fast_learner')) {
            achievements.push({
                id: 'fast_learner',
                title: 'Fast Learner',
                description: 'Completed three cybersecurity lessons',
                icon: 'fa-bolt',
                date: new Date().toISOString()
            });
            user.stats.achievements.push('fast_learner');
        }
        
        // All lessons completed
        if (user.stats.completedLessons === user.stats.totalLessons && 
            !user.stats.achievements.includes('cyber_master')) {
            achievements.push({
                id: 'cyber_master',
                title: 'Cybersecurity Master',
                description: 'Completed all cybersecurity lessons',
                icon: 'fa-crown',
                date: new Date().toISOString()
            });
            user.stats.achievements.push('cyber_master');
        }
        
        return achievements;
    }
    
    checkTestAchievements(user, testResult) {
        const achievements = [];
        
        // First test passed
        if (testResult.score >= 70 && !user.stats.achievements.includes('first_test_passed')) {
            achievements.push({
                id: 'first_test_passed',
                title: 'Test Conqueror',
                description: 'Passed your first cybersecurity test',
                icon: 'fa-check-circle',
                date: new Date().toISOString()
            });
            user.stats.achievements.push('first_test_passed');
        }
        
        // Perfect score
        if (testResult.score === 100 && !user.stats.achievements.includes('perfect_score')) {
            achievements.push({
                id: 'perfect_score',
                title: 'Perfect Score',
                description: 'Achieved a perfect score on a test',
                icon: 'fa-trophy',
                date: new Date().toISOString()
            });
            user.stats.achievements.push('perfect_score');
        }
        
        return achievements;
    }
    
    // Update Learning Streak
    updateStreak(user) {
        const today = new Date().toISOString().split('T')[0];
        const lastActive = user.stats.lastActiveDate;
        
        if (lastActive === today) {
            // Already active today
            return;
        }
        
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];
        
        if (lastActive === yesterdayStr) {
            // Consecutive day
            user.stats.streakDays++;
        } else if (lastActive !== today) {
            // Broken streak
            user.stats.streakDays = 1;
        }
        
        user.stats.lastActiveDate = today;
    }
    
    // Update User Settings
    updateSettings(userId, settings) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return false;
        
        Object.assign(user.settings, settings);
        this.saveUsers();
        
        if (this.currentUser && this.currentUser.id === userId) {
            Object.assign(this.currentUser.settings, settings);
            this.saveCurrentUser();
        }
        
        return true;
    }
    
    // Update Profile
    updateProfile(userId, profileData) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return false;
        
        Object.assign(user, profileData);
        this.saveUsers();
        
        if (this.currentUser && this.currentUser.id === userId) {
            Object.assign(this.currentUser, profileData);
            this.saveCurrentUser();
        }
        
        return true;
    }
    
    // Change Password
    changePassword(userId, currentPassword, newPassword) {
        const user = this.users.find(u => u.id === userId);
        if (!user) return { success: false, message: 'User not found' };
        
        // Verify current password
        if (user.password !== this.hashPassword(currentPassword)) {
            return { success: false, message: 'Current password is incorrect' };
        }
        
        // Update password
        user.password = this.hashPassword(newPassword);
        this.saveUsers();
        
        if (this.currentUser && this.currentUser.id === userId) {
            this.currentUser.password = user.password;
            this.saveCurrentUser();
        }
        
        return { success: true, message: 'Password updated successfully' };
    }
    
    // Helper Methods
    isValidEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    }
    
    hashPassword(password) {
        // In a real application, use a proper hashing algorithm like bcrypt
        // For demo purposes, we'll use a simple hash
        let hash = 0;
        for (let i = 0; i < password.length; i++) {
            const char = password.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash;
        }
        return hash.toString();
    }
    
    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }
    
    saveUsers() {
        localStorage.setItem('fatal_exe_users', JSON.stringify(this.users));
    }
    
    saveCurrentUser() {
        if (this.currentUser) {
            localStorage.setItem('fatal_exe_current_user', JSON.stringify(this.currentUser));
        }
    }
    
    // Get user by email
    getUserByEmail(email) {
        return this.users.find(user => user.email === email);
    }
    
    // Get user by ID
    getUserById(id) {
        return this.users.find(user => user.id === id);
    }
    
    // Get all users (admin only)
    getAllUsers() {
        return this.users;
    }
    
    // Delete user (admin only)
    deleteUser(id) {
        const index = this.users.findIndex(user => user.id === id);
        if (index !== -1) {
            this.users.splice(index, 1);
            this.saveUsers();
            
            // If deleted user is current user, log them out
            if (this.currentUser && this.currentUser.id === id) {
                this.logout();
            }
            
            return true;
        }
        return false;
    }
}

// Export for use in other files
window.UserManager = UserManager;
