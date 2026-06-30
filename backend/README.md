# 貘nsters Backend

貘nsters 的 Spring Boot 後端專案。

## 技術

- JDK 18
- Spring Boot
- Gradle
- MySQL

## MySQL 連線設定

後端透過環境變數讀取 MySQL 連線資訊：

| 環境變數 | 預設值 |
|----------|--------|
| `DB_URL` | `jdbc:mysql://localhost:3306/monsters?useSSL=false&serverTimezone=Asia/Taipei&allowPublicKeyRetrieval=true` |
| `DB_USERNAME` | `monsters` |
| `DB_PASSWORD` | `monsters` |

範例請參閱：

- `src/main/resources/application-example.yml`

## 專案規範

後端開發需遵守：

- `../AGENTS.md`
- `../docs/CODING_STANDARD.md`
- `../docs/API_SPEC.md`
- `../docs/DATABASE_SPEC.md`
