# StockLite Database Design Document

This document provides a detailed technical specification for the Firebase Firestore schema of the StockLite platform.

## Architecture Overview

StockLite uses a **Serverless NoSQL Architecture** powered by Google Cloud Firebase. The data model is optimized for read-heavy operations (catalog browsing) and consistent writes for inventory adjustments.

---

## 1. Collections Schema

### 1.1 `users`
**Path**: `/users/{uid}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | User's full display name |
| `email` | String | Yes | Primary contact email |
| `role` | String | Yes | `ADMIN`, `MANAGER`, `VIEWER` |
| `hub` | String | Yes | Associated warehouse (e.g., "SF Hub") |
| `stats` | Map | No | `{ "itemsTracked": Int, "reportsGenerated": Int }` |
| `avatarUrl` | String | No | Link to Profile image (Cloud Storage) |
| `lastLogin` | Timestamp| Yes | Record of last access |

### 1.2 `products`
**Path**: `/products/{productId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | Commercial name |
| `sku` | String | Yes | Unique SKU code (Unique Index required) |
| `stock` | Number | Yes | Current quantity (Atomic updates recommended) |
| `status` | String | Yes | `IN_STOCK`, `LOW_STOCK`, `OUT_OF_STOCK` |
| `imageUrl` | String | Yes | Primary product image asset |
| `category` | String | Yes | Classification (e.g., "Electronics") |
| `description`| String | No | Full technical specifications |
| `updatedAt` | Timestamp| Yes | Last stock or metadata change |
| `createdAt` | Timestamp| Yes | Initial record creation |

### 1.3 `activity_logs`
**Path**: `/activity_logs/{logId}`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `productId` | String | Yes | Target product reference (Doc ID) |
| `userId` | String | Yes | Actor reference (Auth UID) |
| `type` | String | Yes | `STOCK_INC`, `STOCK_DEC`, `CREATE`, `DELETE` |
| `delta` | Number | Yes | Magnitude of change (+/-) |
| `prevStock` | Number | Yes | Snapshot before operation |
| `timestamp` | Timestamp| Yes | Precise event time |

---

## 2. Indexing Strategy

To maintain performance, the following composite indexes are required:

1.  **Product Catalog Query**:
    - Collection: `products`
    - Fields: `status` (Ascending), `updatedAt` (Descending)
2.  **User Activity Stream**:
    - Collection: `activity_logs`
    - Fields: `userId` (Ascending), `timestamp` (Descending)
3.  **Product History**:
    - Collection: `activity_logs`
    - Fields: `productId` (Ascending), `timestamp` (Descending)

---

## 3. UI Interaction Mapping

| UI Element | Source Collection | Operation Type |
|------------|-------------------|----------------|
| **Inventory Grid** | `products` | Collection Group Query with Status filter |
| **Product Badge** | `products` | Document Read (Real-time listener) |
| **Stock Adjust** | `activity_logs` | Transactional Write (Increment + Log) |
| **Profile Stats** | `users` | Document Read |

---
*Document Version: 1.1*
*Link to Project ID: stocklite-5c598*
