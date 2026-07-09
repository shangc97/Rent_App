# AuthStore 和 AuthRepository 理解文档

这份文档的目标不是重复代码，而是帮你真正分清：

1. `AuthRepository` 到底负责什么
2. `AuthStore` 到底负责什么
3. 为什么“登录成功”在你的项目里不等于“整个 app session 已经完成”

---

## 1. 先看一句话版本

如果只用一句话概括：

- `AuthRepository`：直接和 FirebaseAuth 对话，做最底层的认证操作
- `AuthStore`：给 SwiftUI 页面用的状态层，负责 loading、error、currentUserId

所以它们的关系可以理解成：

`View -> AuthStore -> AuthRepository -> FirebaseAuth`

---

## 2. 它们各自的位置

对应文件：

- `AuthRepository` 在 [AuthRepository.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Core/Repositories/AuthRepository.swift)
- `AuthStore` 在 [AuthStore.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Core/Stores/AuthStore.swift)

你当前项目里的分层思路是：

- `Repository` 负责“碰数据库 / 碰 Firebase SDK”
- `Store` 负责“给界面提供可观察状态”
- `AppSessionCoordinator` 负责“跨多个 store 的完整 session 编排”

所以从职责边界来说：

- `AuthRepository` 不应该关心 UI
- `AuthStore` 不应该直接写 Firebase API 细节
- “登录后进入 landlord/tenant 正确主页”这件事，其实也不只属于 `AuthStore`

---

## 3. AuthRepository 是做什么的

`AuthRepository` 很纯粹，它只是 Firebase Authentication 的一个轻量封装。

它现在只有 4 个职责：

### `currentUserId()`

作用：

- 从 `Auth.auth().currentUser?.uid` 读取当前 Firebase session 对应的 uid

它回答的问题是：

- “Firebase 现在有没有一个已经登录过的用户？”

它**不**回答这些问题：

- 这个用户是 landlord 还是 tenant
- 这个用户的 profile 有没有建好
- 这个用户能不能进入 app 主流程

### `createAccount(email:password:)`

作用：

- 调用 FirebaseAuth 创建账号
- 成功后返回新用户的 `uid`

它只做“认证账号创建”，不做：

- Firestore 用户资料创建
- role 写入
- appState 更新

### `signIn(email:password:)`

作用：

- 调用 FirebaseAuth 登录
- 成功后返回 `uid`

它也只负责 Firebase 层面的登录成功，不负责：

- 加载 `UserProfile`
- 判断角色
- 决定跳到 tenant 还是 landlord

### `signOut()`

作用：

- 调用 FirebaseAuth 的 `signOut()`

它只负责把 Firebase session 清掉。

---

## 4. AuthStore 是做什么的

`AuthStore` 是给 SwiftUI 页面直接使用的那一层。

它多做了三件 `AuthRepository` 不做的事：

1. 管理 `isLoading`
2. 管理 `errorMessage`
3. 保存当前认证成功得到的 `currentUserId`

也就是说，`AuthStore` 的重点是：

- 让页面知道“现在是不是正在登录/注册”
- 让页面知道“有没有报错”
- 让页面知道“Firebase auth 现在拿到哪个 uid 了”

### `currentUserId`

这是一个很关键的点。

你现在的 `AuthStore.currentUserId` 表示的是：

- “Firebase authentication 成功后的 uid”

它**不表示**：

- app 已经完整进入 authenticated session

因为在你的项目里，完整 session 还需要后续这一步：

- 用这个 uid 去 Firestore 读取 `UserProfile`
- 再根据 profile 里的 `role` 写入 `AppState`

所以可以这样理解：

- `AuthStore.currentUserId` = 认证层成功
- `AppState.currentUserRole/currentUserId` = app 会话层成功

这两个层级是分开的。

### `restoreSession()`

这个方法只是：

- 调 `authRepository.currentUserId()`
- 把结果塞回 `AuthStore.currentUserId`

也就是说它只是“恢复 Firebase 认证状态”，不是“恢复整个 app 的已登录状态”。

### `createAccount(email:password:)`

这个方法做的事：

1. `isLoading = true`
2. 清空旧错误
3. 调 `authRepository.createAccount(...)`
4. 成功后把返回的 uid 写到 `currentUserId`
5. 失败就把错误写入 `errorMessage`
6. 最后 `isLoading = false`

所以它是一个“带 UI 状态的注册包装层”。

### `signIn(email:password:)`

逻辑和 `createAccount` 一样，只是底层调用改成 `authRepository.signIn(...)`

### `signOut()`

这个方法会：

1. 调 `authRepository.signOut()`
2. 成功后把 `currentUserId = nil`
3. 如果失败，把错误写到 `errorMessage`

但它仍然只是在 auth 这一层做清理。

如果你还要清：

- `UserProfileStore`
- `ShortlistPropertyStore`
- `RentalRequestStore`
- `AppState`

那就不是 `AuthStore` 单独负责，而是 `AppSessionCoordinator.signOutCurrentSession(...)` 来做。

---

## 5. 为什么还需要 AppSessionCoordinator

这是理解你当前架构最重要的一点。

很多人会自然以为：

- 登录成功 = `AuthStore.signIn()` 成功

但在你这个项目里，不够。

因为 FirebaseAuth 只知道：

- 这个 email/password 对不对
- 这个 uid 是谁

它不知道：

- 这个用户是不是 tenant
- 这个用户是不是 landlord
- Firestore 里的 profile 有没有准备好

所以你又加了一层：

- [AppSessionCoordinator.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/App/AppSessionCoordinator.swift)

它负责把多个步骤串起来，变成“完整业务 session”。

最关键的方法是：

- `activateAuthenticatedSession(...)`

它做的是：

1. 用 `userId` 去 `UserProfileStore.loadUserProfile`
2. 拿到 `currentUserProfile`
3. 读出 `role`
4. 再写进 `AppState`

所以真正决定“进入 tenant flow 还是 landlord flow”的，不是 `AuthStore`，而是：

- `AppSessionCoordinator + UserProfileStore + AppState`

---

## 6. 现在这套登录流程到底怎么走

## 6.1 Sign In 流程

在 [AuthLandingView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Auth/AuthLandingView.swift) 里，登录流程是：

1. 用户输入 email/password
2. 调 `authStore.signIn(...)`
3. `AuthStore` 再调 `AuthRepository.signIn(...)`
4. FirebaseAuth 返回 uid
5. `AuthStore.currentUserId` 被写入
6. 页面拿到这个 uid 后，再调 `AppSessionCoordinator.activateAuthenticatedSession(...)`
7. `UserProfileStore` 去 Firestore 加载 profile
8. `AppState` 根据 profile.role 进入正确 session

这说明：

- `AuthStore.signIn()` 只是认证成功
- `activateAuthenticatedSession()` 才是业务 session 成功

---

## 6.2 Sign Up 流程

在 [SignUpView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Auth/SignUpView.swift) 里，注册流程是：

1. 调 `authStore.createAccount(...)`
2. FirebaseAuth 创建账号，返回 uid
3. `AuthStore.currentUserId` 被写入
4. 页面自己组装一个 `UserProfile`
5. `UserProfileStore.createUserProfile(...)`
6. 如果 profile 创建成功，再调 `AppSessionCoordinator.activateAuthenticatedSession(...)`
7. 最后 `AppState` 进入对应角色 session

所以注册流程比登录多一步：

- 先建 Auth 账号
- 再建 Firestore profile

这也是为什么 `AuthRepository` 不负责注册完整业务用户，它只负责 auth account。

---

## 6.3 Sign Out 流程

比如在 [ProfileView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Profile/ProfileView.swift) 里，登出不是直接调 `authStore.signOut()` 就结束了，而是走：

- `AppSessionCoordinator.signOutCurrentSession(...)`

内部流程是：

1. `authStore.signOut()`
2. 如果 auth 层没报错
3. 清空 `UserProfileStore`
4. 清空 `ShortlistPropertyStore`
5. 清空 `RentalRequestStore`
6. `appState.showLoggedOut()`

这就说明：

- `AuthStore.signOut()` 只清认证
- `AppSessionCoordinator.signOutCurrentSession()` 才清完整 session

---

## 7. Launch 时为什么会先 restoreSession 再 signOut

你现在在 `resetLaunchSessionToLoggedOut(...)` 里的逻辑比较特别：

1. `authStore.restoreSession()`
2. 如果发现 Firebase 里其实有用户
3. 立刻 `authStore.signOut()`
4. 然后 app 回到 logged out

这样设计的原因是你现在的产品逻辑改成了：

- app 重启后默认还是进入 `AuthLandingView`
- remember me 只负责“自动填入 email/password”
- 不负责“自动直接登录”

所以这段逻辑的意思不是多余，而是：

- 不允许 Firebase 静默保留上次登录 session 直接进入 app

---

## 8. 你可以怎么判断“某个逻辑该写在哪层”

这是最实用的一部分。

### 应该写进 AuthRepository 的逻辑

特征：

- 直接调用 FirebaseAuth API
- 不需要关心 SwiftUI 页面状态
- 不需要关心角色、导航、页面切换

例子：

- create user
- sign in
- sign out
- read current firebase uid

### 应该写进 AuthStore 的逻辑

特征：

- 要给页面一个可观察状态
- 要管理 loading/error
- 仍然主要属于“auth 这一层”

例子：

- 注册按钮点击后显示 loading
- 登录失败后显示 error message
- 保存当前 auth uid

### 不应该写进 AuthStore 的逻辑

这些更适合放在 `AppSessionCoordinator` 或其他 store：

- 根据 uid 加载 `UserProfile`
- 根据 role 决定进入 tenant/landlord
- remember me 的 UserDefaults/Keychain 持久化
- 登出时清空所有用户作用域数据

---

## 9. 这两个类型的核心区别

你可以用一句最稳的判断方式：

- `AuthRepository` 关注“怎么和 Firebase 认证系统说话”
- `AuthStore` 关注“页面现在该显示什么认证状态”

一个偏底层，一个偏界面状态。

---

## 10. 当前这套设计的优点

### 优点 1

分层清楚。UI 不直接碰 FirebaseAuth。

### 优点 2

`AuthStore` 统一管理 `isLoading` 和 `errorMessage`，页面写起来更干净。

### 优点 3

“认证成功”和“完整 session 激活成功”被分开了，这很适合你现在这种有角色、有 profile 的项目。

### 优点 4

以后如果你想换认证实现，理论上优先动 `AuthRepository`，上层受影响会更小。

---

## 11. 当前这套设计最容易混淆的点

### 混淆点 1

`AuthStore.currentUserId` 不等于 `AppState.currentUserId`

前者表示：

- Firebase auth 成功了

后者表示：

- 整个 app session 已经确认好了

### 混淆点 2

`AuthStore.signIn()` 不等于“可以直接进主页”

中间还需要：

- load profile
- resolve role
- update appState

### 混淆点 3

Remember Me 不属于 `AuthStore`

它现在属于：

- `AppSessionCoordinator`

因为它已经不是单纯的 auth SDK 调用了，而是 session experience 的编排。

---

## 12. 你可以把它们记成这张图

```text
AuthLandingView / SignUpView
        |
        v
    AuthStore
        |
        v
  AuthRepository
        |
        v
   FirebaseAuth

认证成功后
        |
        v
AppSessionCoordinator
        |
        v
UserProfileStore -> Firestore profile
        |
        v
     AppState
        |
        v
Tenant / Landlord flow
```

---

## 13. 最后给你的一个最简记忆法

如果你以后又看乱了，只记这三句就够了：

1. `AuthRepository` 只管 FirebaseAuth
2. `AuthStore` 只管 auth 状态
3. “真正进入 app” 要靠 `AppSessionCoordinator` 把 auth + profile + role 串起来
