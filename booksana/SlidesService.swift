import Foundation
import Supabase

final class SlidesService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    static let shared = SlidesService(client: SupabaseManager.shared.client)

    // Fetch active slides for a given book, ordered by order_index asc
    func fetchSlides(bookID: Int) async throws -> [Slide] {
        return try await {
            let response = try await client.database
                .from("slides")
                .select("*")
                .eq("book_id", value: bookID)
                .eq("is_active", value: true)
                .order("order_index", ascending: true)
                .execute()

#if DEBUG
            print("SlidesService.fetchSlides: book_id=\(bookID), bytes=\(response.data.count)")
            if let raw = String(data: response.data, encoding: .utf8) {
                print("SlidesService.fetchSlides: raw preview=\(raw.prefix(500))")
            }
#endif

            let decoder = JSONDecoder()
            // Accept ISO8601 with and without fractional seconds
            let isoWithFraction = ISO8601DateFormatter()
            isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let isoNoFraction = ISO8601DateFormatter()
            isoNoFraction.formatOptions = [.withInternetDateTime]

            decoder.dateDecodingStrategy = .custom { dec in
                let c = try dec.singleValueContainer()
                let s = try c.decode(String.self)
                if let d = isoWithFraction.date(from: s) ?? isoNoFraction.date(from: s) {
                    return d
                }
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Expected ISO8601 (with/without fractional seconds), got: \(s)")
            }
            // Slide has explicit snake_case CodingKeys, so do NOT convert keys automatically
            decoder.keyDecodingStrategy = .useDefaultKeys

            do {
                return try decoder.decode([Slide].self, from: response.data)
            } catch let DecodingError.dataCorrupted(ctx) {
                print("DecodingError.dataCorrupted:", ctx.debugDescription, "path:", ctx.codingPath)
                throw DecodingError.dataCorrupted(ctx)
            } catch let DecodingError.keyNotFound(key, ctx) {
                print("KeyNotFound:", key.stringValue, "path:", ctx.codingPath)
                throw DecodingError.keyNotFound(key, ctx)
            } catch let DecodingError.typeMismatch(type, ctx) {
                print("TypeMismatch:", type, "path:", ctx.codingPath)
                throw DecodingError.typeMismatch(type, ctx)
            } catch let DecodingError.valueNotFound(value, ctx) {
                print("ValueNotFound:", value, "path:", ctx.codingPath)
                throw DecodingError.valueNotFound(value, ctx)
            } catch {
                print("Other decoding error:", error)
                throw error
            }
        }()
    }

    // Safe fetch with placeholder fallback for previews / offline
    func fetchSlidesSafe(bookID: Int) async -> [Slide] {
        do {
            return try await fetchSlides(bookID: bookID)
        } catch {
            #if DEBUG
            print("SlidesService.fetchSlidesSafe error:", error)
            // Fallback to placeholder data from the model helper (DEBUG only)
            return Slide.placeholder().map { slide in
                // Ensure placeholder book_id matches requested book for consistency
                Slide(
                    id: slide.id,
                    created_at: slide.created_at,
                    updated_at: slide.updated_at,
                    book_id: bookID,
                    order_index: slide.order_index,
                    image_url: slide.image_url,
                    video_mp4_url: slide.video_mp4_url,
                    audio_mp3_url: slide.audio_mp3_url,
                    eyebrow: slide.eyebrow,
                    title_1: slide.title_1,
                    title_2: slide.title_2,
                    lead_md: slide.lead_md,
                    body_md: slide.body_md,
                    text_alignment: slide.text_alignment,
                    content_color: slide.content_color,
                    background_color: slide.background_color,
                    is_active: slide.is_active,
                    valid_from: slide.valid_from,
                    valid_to: slide.valid_to
                )
            }
            #else
            // In Release: empty state is safer than masking errors with placeholders
            return []
            #endif
        }
    }
}
