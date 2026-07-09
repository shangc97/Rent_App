# AppSessionCoordinator 理解文档

这份文档的目标是帮你真正理解：

1. `AppSessionCoordinator` 为什么存在
2. 它和 `AuthStore`、`AppState`、`UserProfileStore` 的区别
3. 它里面每个方法在你项目里的真实作用

对应源码文件：

- [AppSessionCoordinator.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/App/AppSessionCoordinator.swift)

---

## 1. 先看一句话版本

如果只用一句话概括：

`AppSessionCoordinator` 是“会话流程总协调器”，专门负责那些**跨多个 store / 跨多个层级**的 session 逻辑。

它不直接负责：

- 渲染 UI
- 直接调 FirebaseAuth 登录
- 单独管理某一个 store 的内部状态

它负责的是：

- 把多个步骤串起来，变成“完整 session 行为”

---

## 2. 为什么它需要存在

如果项目里只有：

- `AuthStore`
- `UserProfileStore`
- `AppState`

那你会很快遇到一个问题：

很多操作其实不是某一个 store 单独能完成的。

比如“登录成功”这件事，在你的项目里并不是一个单步骤动作。

它至少包含这些环节：

1. FirebaseAuth 登录成功
2. 拿到 `uid`
3. 去 Firestore 读这个用户的 `UserProfile`
4. 读出 `role`
5. 写入 `AppState`
6. 最后 root flow 才能跳到 tenant 或 landlord

这时候问题就来了：

- 这些步骤不该都塞进 `AuthStore`
- 也不该散落在每个 View 里各写一遍

所以你需要一个“负责串流程”的地方。

这个地方就是：

- `AppSessionCoordinator`

---

## 3. 它不是数据层，也不是页面状态层

这是最关键的理解点。

### 它不是 Repository

Repository 的职责是：

- 和 Firebase / Firestore 直接通信

比如：

- `AuthRepository`
- `UserProfileRepository`

### 它不是 Store

Store 的职责是：

- 管理某一块可观察状态
- 给 SwiftUI 页面消费

比如：

- `AuthStore`
- `UserProfileStore`
- `ShortlistPropertyStore`
- `RentalRequestStore`

### 它是 Coordinator

Coordinator 的职责是：

- 调用多个 store
- 决定执行顺序
- 处理“一个完整用户动作”需要跨哪些状态层

所以它的重点不是“保存数据”，而是“组织流程”。

---

## 4. 你可以把它理解成什么

最适合你的理解方式是：

`AppSessionCoordinator` = session 业务规则的指挥中心

它负责回答这些问题：

- 登录成功后，接下来要做什么？
- 注册成功后，什么时候才算真正进入 app？
- 退出登录时，哪些 store 要一起清空？
- app 启动时，应该进哪里？
- remember me 的信息要怎么保存和恢复？

这些问题都不是某一个单独模型的责任。

---

## 5. 为什么它被写成 `enum` + `static func`

你当前的写法是：

```swift
@MainActor
enum AppSessionCoordinator
```

这表示它不是“要被实例化的对象”，而是一个纯工具型协调器。

这样写的含义是：

- 不需要 `AppSessionCoordinator()`
- 不需要自己持有状态
- 只需要提供一组统一入口方法

这很适合它现在的职责，因为它本质上就是“流程函数集合”。

---

## 6. 它解决的核心问题

### 问题 1：认证成功不等于完整 session 成功

`AuthStore.signIn(...)` 成功，只代表：

- FirebaseAuth 验证通过了
- 你拿到了 `uid`

但这还不够，因为 app 还不知道：

- 这个用户是 tenant 还是 landlord

所以还必须继续做：

- 读取 `UserProfile`
- 拿到 `role`
- 更新 `AppState`

这个跨层动作由 `AppSessionCoordinator.activateAuthenticatedSession(...)` 完成。

### 问题 2：登出不只是 `auth.signOut()`

在你的项目里，登出以后还应该清掉：

- `UserProfileStore`
- `ShortlistPropertyStore`
- `RentalRequestStore`
- `AppState`

所以“登出当前 session”不是 `AuthStore` 一个人能完整负责的。

这个跨层动作由 `AppSessionCoordinator.signOutCurrentSession(...)` 完成。

### 问题 3：remember me 也不是单独某个 store 的工作

remember me 既不是：

- FirebaseAuth 的直接职责

也不是：

- 某个单一页面状态的职责

它更像“登录体验策略”的一部分，所以被放进 `AppSessionCoordinator`。

---

## 7. 每个方法在干什么

## 7.1 `activateAuthenticatedSession(...)`

这是整个文件里最核心的方法。

作用：

- 用 `userId` 加载 `UserProfile`
- 拿到角色
- 把完整 authenticated session 写进 `AppState`

内部流程：

1. `userProfileStore.loadUserProfile(userId:)`
2. 确认 `currentUserProfile` 真的加载成功
3. 调 `appState.setAuthenticatedSession(...)`

你可以把它理解成：

- “把认证成功的 uid，升级成真正可进入 app 的用户 session”

如果没有它，`AuthLandingView` 和 `SignUpView` 都得自己写一大段：

- load profile
- check profile
- extract role
- write appState

这样逻辑会重复。

---

## 7.2 `resetLaunchSessionToLoggedOut(...)`

这个方法在 app 启动时使用。

调用点在：

- [RootView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/App/RootView.swift)

它的作用是：

- 把 app 从 `.loading` 准备到真正的初始可见状态

你当前的产品逻辑是：

- app 重启后默认进入登录页
- remember me 只负责自动填充账号密码
- 不自动直接登录

所以它做的事是：

1. `authStore.restoreSession()`
2. 如果 Firebase 里居然还有旧 session，就主动 `signOut()`
3. 清空 `UserProfileStore`
4. `appState.showLoggedOut()`

它的真实含义是：

- “把系统强制整理回你想要的 launch 入口状态”

---

## 7.3 `activateGuestSession(...)`

作用：

- 进入 guest flow
- 同时清空所有用户作用域的数据

它会清：

- `UserProfileStore`
- `ShortlistPropertyStore`
- `RentalRequestStore`

然后：

- `appState.continueAsGuest()`

这很重要，因为 guest 不是单纯“没登录”，而是一个明确的 session 模式。

---

## 7.4 `updateRememberedCredentials(...)`

作用：

- 在用户勾选 remember me 时保存信息
- 不勾选时清空信息

它会保存：

- `userId` 到 `UserDefaults`
- `email` 到 `UserDefaults`
- `password` 到 Keychain

为什么 password 不放 `UserDefaults`：

- 因为相对更敏感，所以你现在把它放进 Keychain

这也是这个 coordinator 文件里引入 `Security` 的原因。

---

## 7.5 `rememberedCredentials()`

作用：

- 尝试读出之前 remember me 存下来的信息

如果三样都拿到：

- `userId`
- `email`
- `password`

就返回一个 `RememberedCredentials`

否则返回 `nil`

这个方法主要给登录页预填表单使用。

调用点在：

- [AuthLandingView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Auth/AuthLandingView.swift)

---

## 7.6 `signOutCurrentSession(...)`

这是“完整登出流程”的统一入口。

作用：

1. 调 `authStore.signOut()`
2. 如果 auth 层没有报错
3. 清空用户作用域 store
4. `appState.showLoggedOut()`

调用点在：

- [ProfileView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Profile/ProfileView.swift)

所以它不是“只登 Firebase”，而是：

- “把整个 app 会话安全地退回到 logged out 状态”

---

## 7.7 `clearUserScopedStores(...)`

这是个私有辅助方法。

它的作用是把这三件事统一封装起来：

- `userProfileStore.clearUserProfile()`
- `shortlistPropertyStore.clearShortlist()`
- `rentalRequestStore.clearRentalRequests()`

这样 `activateGuestSession(...)` 和 `signOutCurrentSession(...)` 就不用重复写同样的清理代码。

---

## 7.8 remember me 相关的私有方法

包括：

- `clearRememberedCredentials()`
- `saveRememberedPassword(...)`
- `rememberedPassword(for:)`
- `deleteRememberedPassword(for:)`

这几段都属于 remember me 的持久化实现细节。

你可以把它们理解成：

- coordinator 内部为了支持 remember me 而封装的本地存储工具

它们不需要暴露给外部页面直接调用。

---

## 8. 实际流程里它怎么工作

## 8.1 Sign In 时

在 [AuthLandingView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Auth/AuthLandingView.swift) 里：

1. 页面先调 `authStore.signIn(...)`
2. FirebaseAuth 成功后拿到 uid
3. 再调 `AppSessionCoordinator.activateAuthenticatedSession(...)`
4. profile 加载成功后，`AppState` 才进入 tenant 或 landlord
5. 最后更新 remember me

所以：

- `AuthStore` 负责 auth
- `AppSessionCoordinator` 负责把 auth 结果升级成完整 session

---

## 8.2 Sign Up 时

在 [SignUpView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Auth/SignUpView.swift) 里：

1. 页面先调 `authStore.createAccount(...)`
2. 成功后构造 `UserProfile`
3. `userProfileStore.createUserProfile(...)`
4. 然后再调 `AppSessionCoordinator.activateAuthenticatedSession(...)`

所以注册流程里，它负责的是：

- “profile 建好以后，正式激活 app session”

---

## 8.3 App Launch 时

在 [RootView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/App/RootView.swift) 里：

1. app 先处于 `.loading`
2. `RootView.task` 调 `resetLaunchSessionToLoggedOut(...)`
3. coordinator 整理出 launch 后应该显示的状态
4. 最后 `sessionState` 变成 `.loggedOut`
5. root 切到登录页

---

## 8.4 Sign Out 时

在 [ProfileView.swift](/Users/shangc/Desktop/3-Advanced%20iOS/Project/Rent_Project/Rent_Project/Features/Profile/ProfileView.swift) 里：

1. 用户点击 log out
2. 调 `AppSessionCoordinator.signOutCurrentSession(...)`
3. auth 层登出
4. user-scoped stores 被清空
5. appState 切回 `.loggedOut`

---

## 9. 如果没有这个文件，会发生什么

如果没有 `AppSessionCoordinator`，这些问题很容易出现：

### 问题 1

`AuthLandingView` 和 `SignUpView` 会各自复制一套 session 激活逻辑。

### 问题 2

登出逻辑会分散在很多页面里，清理不一致。

### 问题 3

remember me 的逻辑会混进某个 View 或某个 Store，边界会变乱。

### 问题 4

以后你想改启动策略、改 remember me、改登出清理时，要改很多地方。

所以它的价值不是“帮你少写一两个函数”，而是：

- 把 session 业务规则集中在一个地方

---

## 10. 它和其他类型的区别

你可以这样记：

- `AuthRepository`：和 FirebaseAuth 说话
- `AuthStore`：提供 auth loading/error/currentUserId
- `UserProfileStore`：提供 profile 数据
- `AppState`：决定 app 当前走哪个 root flow
- `AppSessionCoordinator`：把上面这些东西按正确顺序串起来

这是它最准确的定位。

---

## 11. 最简记忆法

如果你以后又看乱了，只记这三句就够了：

1. `AuthStore` 解决“认证是否成功”
2. `AppState` 解决“现在 app 应该显示哪个 flow”
3. `AppSessionCoordinator` 解决“怎么从一个状态安全地切到另一个状态”

---

## 12. 你现在这版项目里，它最核心的三个价值

### 价值 1

统一 authenticated session 激活流程

### 价值 2

统一 sign out 和 guest 切换时的清理流程

### 价值 3

统一 remember me 的持久化和恢复逻辑

如果没有这三类统一入口，session 相关代码会很快散掉。
