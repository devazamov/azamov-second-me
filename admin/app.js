/// ═══════════════════════════════════════════════════════════════
/// AZAMOV Second Me - Admin Dashboard JavaScript
/// Firebase-powered admin panel for managing users, missions, etc.
/// ═══════════════════════════════════════════════════════════════

// ─── Firebase Configuration ───
// TODO: Replace with your actual Firebase config
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
};

firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const auth = firebase.auth();

// ═══════════════════════════════════════════════════════════════
// NAVIGATION
// ═══════════════════════════════════════════════════════════════

const navItems = document.querySelectorAll('.nav-item');
const pages = document.querySelectorAll('.page');
const pageTitle = document.getElementById('page-title');

navItems.forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        const page = item.dataset.page;

        // Update active nav
        navItems.forEach(n => n.classList.remove('active'));
        item.classList.add('active');

        // Show page
        pages.forEach(p => p.classList.remove('active'));
        document.getElementById(`page-${page}`).classList.add('active');

        // Update title
        pageTitle.textContent = item.querySelector('span:last-child').textContent;
    });
});

// ═══════════════════════════════════════════════════════════════
// DASHBOARD STATS
// ═══════════════════════════════════════════════════════════════

async function loadDashboardStats() {
    try {
        // Total users
        const usersSnapshot = await db.collection('users').get();
        const totalUsers = usersSnapshot.size;
        document.getElementById('total-users').textContent = totalUsers;

        // Premium users
        let premiumCount = 0;
        usersSnapshot.forEach(doc => {
            if (doc.data().isPremium) premiumCount++;
        });
        document.getElementById('premium-users').textContent = premiumCount;

        // Daily active (users active today)
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        let dailyActive = 0;
        usersSnapshot.forEach(doc => {
            const lastActive = doc.data().lastActiveDate;
            if (lastActive && lastActive.toDate() >= today) {
                dailyActive++;
            }
        });
        document.getElementById('daily-active').textContent = dailyActive;

        // Revenue (premium users × 49000 UZS)
        const revenue = premiumCount * 49000;
        document.getElementById('revenue').textContent =
            revenue.toLocaleString() + ' UZS';

        // Load charts
        loadUserGrowthChart();
        loadFeatureUsageChart();
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// ═══════════════════════════════════════════════════════════════
// USERS TABLE
// ═══════════════════════════════════════════════════════════════

async function loadUsers() {
    const tbody = document.getElementById('users-table-body');
    try {
        const snapshot = await db.collection('users')
            .orderBy('createdAt', 'desc')
            .limit(50)
            .get();

        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Foydalanuvchilar topilmadi</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const user = doc.data();
            const userId = doc.id;
            html += `
                <tr>
                    <td><strong>${user.name || 'Noma\'lum'}</strong></td>
                    <td>${user.email || '-'}</td>
                    <td>${user.age || '-'}</td>
                    <td><span class="badge badge-info">Lv.${user.level || 1}</span></td>
                    <td>${user.currentStreak || 0} kun</td>
                    <td>${user.isPremium
                        ? '<span class="badge badge-success">Premium</span>'
                        : '<span class="badge badge-warning">Bepul</span>'
                    }</td>
                    <td>
                        <button class="btn btn-sm btn-secondary" onclick="viewUser('${userId}')">Ko'rish</button>
                        <button class="btn btn-sm btn-danger" onclick="blockUser('${userId}')">Bloklash</button>
                    </td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    } catch (error) {
        console.error('Error loading users:', error);
        tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Xatolik yuz berdi</td></tr>';
    }
}

// Search users
document.getElementById('user-search')?.addEventListener('input', async (e) => {
    const query = e.target.value.toLowerCase();
    const tbody = document.getElementById('users-table-body');
    const rows = tbody.querySelectorAll('tr');
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
    });
});

async function viewUser(userId) {
    try {
        const doc = await db.collection('users').doc(userId).get();
        if (doc.exists) {
            const user = doc.data();
            alert(`👤 ${user.name}\n📧 ${user.email}\n🎂 ${user.age} yosh\n⭐ Level ${user.level}\n🔥 Streak: ${user.currentStreak} kun\n💎 Premium: ${user.isPremium ? 'Ha' : 'Yo\'q'}`);
        }
    } catch (error) {
        console.error('Error viewing user:', error);
    }
}

async function blockUser(userId) {
    if (confirm('Foydalanuvchini bloklashni xohlaysizmi?')) {
        try {
            await db.collection('users').doc(userId).update({
                isBlocked: true,
                updatedAt: firebase.firestore.FieldValue.serverTimestamp()
            });
            loadUsers();
            alert('Foydalanuvchi bloklandi');
        } catch (error) {
            console.error('Error blocking user:', error);
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MISSIONS MANAGEMENT
// ═══════════════════════════════════════════════════════════════

async function loadMissions() {
    const tbody = document.getElementById('missions-table-body');
    try {
        const snapshot = await db.collection('missions').get();

        if (snapshot.empty) {
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Vazifalar topilmadi. Birinchi vazifani qo\'shing!</td></tr>';
            return;
        }

        let html = '';
        snapshot.forEach(doc => {
            const mission = doc.data();
            const missionId = doc.id;
            html += `
                <tr>
                    <td style="font-size: 24px;">${mission.emoji || '🎯'}</td>
                    <td><strong>${mission.title || '-'}</strong></td>
                    <td><span class="badge badge-info">${mission.category || '-'}</span></td>
                    <td><span class="badge badge-${mission.difficulty === 'easy' ? 'success' : mission.difficulty === 'medium' ? 'warning' : 'error'}">${mission.difficulty || '-'}</span></td>
                    <td>${mission.xpReward || 0}</td>
                    <td>${mission.isPremium ? '💎' : '-'}</td>
                    <td>
                        <button class="btn btn-sm btn-secondary" onclick="editMission('${missionId}')">Tahrirlash</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteMission('${missionId}')">O'chirish</button>
                    </td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    } catch (error) {
        console.error('Error loading missions:', error);
    }
}

// Mission modal
const missionModal = document.getElementById('mission-modal');
const addMissionBtn = document.getElementById('add-mission-btn');
const closeMissionModal = document.getElementById('close-mission-modal');
const cancelMission = document.getElementById('cancel-mission');
const missionForm = document.getElementById('mission-form');

addMissionBtn?.addEventListener('click', () => missionModal.classList.add('active'));
closeMissionModal?.addEventListener('click', () => missionModal.classList.remove('active'));
cancelMission?.addEventListener('click', () => missionModal.classList.remove('active'));

missionForm?.addEventListener('submit', async (e) => {
    e.preventDefault();
    try {
        await db.collection('missions').add({
            emoji: document.getElementById('mission-emoji').value,
            title: document.getElementById('mission-title').value,
            description: document.getElementById('mission-description').value,
            category: document.getElementById('mission-category').value,
            difficulty: document.getElementById('mission-difficulty').value,
            xpReward: parseInt(document.getElementById('mission-xp').value),
            estimatedMinutes: parseInt(document.getElementById('mission-time').value),
            isPremium: document.getElementById('mission-premium').checked,
            isActive: true,
            createdAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        missionModal.classList.remove('active');
        missionForm.reset();
        loadMissions();
        alert('Vazifa qo\'shildi!');
    } catch (error) {
        console.error('Error adding mission:', error);
        alert('Xatolik: ' + error.message);
    }
});

async function deleteMission(missionId) {
    if (confirm('Vazifani o\'chirishni xohlaysizmi?')) {
        try {
            await db.collection('missions').doc(missionId).delete();
            loadMissions();
        } catch (error) {
            console.error('Error deleting mission:', error);
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFICATIONS
// ═══════════════════════════════════════════════════════════════

document.getElementById('notification-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const title = document.getElementById('notif-title').value;
    const body = document.getElementById('notif-body').value;
    const imageUrl = document.getElementById('notif-image').value;

    try {
        await db.collection('notifications').add({
            title,
            body,
            imageUrl: imageUrl || null,
            type: 'broadcast',
            isActive: true,
            createdAt: firebase.firestore.FieldValue.serverTimestamp()
        });
        e.target.reset();
        alert('Xabar yuborildi!');
    } catch (error) {
        console.error('Error sending notification:', error);
        alert('Xatolik: ' + error.message);
    }
});

// ═══════════════════════════════════════════════════════════════
// CHARTS
// ═══════════════════════════════════════════════════════════════

function loadUserGrowthChart() {
    const ctx = document.getElementById('user-growth-chart');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Dush', 'Sesh', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'],
            datasets: [{
                label: 'Yangi foydalanuvchilar',
                data: [12, 19, 8, 15, 22, 14, 18],
                borderColor: '#3A9BDC',
                backgroundColor: 'rgba(58, 155, 220, 0.1)',
                fill: true,
                tension: 0.4,
                pointBackgroundColor: '#3A9BDC',
                pointRadius: 4,
                borderWidth: 2,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, grid: { color: '#E8EAEE' } },
                x: { grid: { display: false } }
            }
        }
    });
}

function loadFeatureUsageChart() {
    const ctx = document.getElementById('feature-usage-chart');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['AI Chat', 'Vazifalar', 'Progress', 'Profil'],
            datasets: [{
                data: [45, 25, 20, 10],
                backgroundColor: ['#3A9BDC', '#34C759', '#FF9F0A', '#6366F1'],
                borderWidth: 0,
                borderRadius: 4,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { padding: 16, usePointStyle: true }
                }
            },
            cutout: '65%',
        }
    });
}

// ═══════════════════════════════════════════════════════════════
// AUTH
// ═══════════════════════════════════════════════════════════════

document.getElementById('logout-btn')?.addEventListener('click', async () => {
    if (confirm('Chiqishni xohlaysizmi?')) {
        await auth.signOut();
        window.location.reload();
    }
});

// ═══════════════════════════════════════════════════════════════
// INITIALIZE
// ═══════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
    loadDashboardStats();
    loadUsers();
    loadMissions();
});
