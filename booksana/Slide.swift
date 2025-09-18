import Foundation

public struct Slide: Codable, Identifiable, Sendable {
    public let id: UUID
    public let created_at: Date?
    public let updated_at: Date?
    public let book_id: Int
    public let order_index: Int
    public let image_url: URL?
    public let video_mp4_url: URL?
    public let audio_mp3_url: URL?
    public let eyebrow: String?
    public let title_1: String?
    public let title_2: String?
    public let lead_md: String?
    public let body_md: String?
    public let text_alignment: String?
    public let content_color: String?
    public let background_color: String?
    public let is_active: Bool
    public let valid_from: Date?
    public let valid_to: Date?
    
    public var lead: String? { lead_md }
    public var body: String? { body_md }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case created_at
        case updated_at
        case book_id
        case order_index
        case image_url
        case video_mp4_url
        case audio_mp3_url
        case eyebrow
        case title_1
        case title_2
        case lead_md
        case body_md
        case text_alignment
        case content_color
        case background_color
        case is_active
        case valid_from
        case valid_to
    }
    
    public static func placeholder() -> [Slide] {
        [
            Slide(
                id: UUID(),
                created_at: Date(),
                updated_at: Date(),
                book_id: 1,
                order_index: 1,
                image_url: URL(string: "https://picsum.photos/seed/1/600/400"),
                video_mp4_url: nil,
                audio_mp3_url: nil,
                eyebrow: "Eyebrow 1",
                title_1: "Dlaczego ta filozofia działa nawet dziś?",
                title_2: "„Nie rzeczy same w sobie nas niepokoją, lecz nasze wyobrażenia o nich.”",
                lead_md: "Nie kontrolujesz świata. Ale kontrolujesz siebie – swoje myśli, wybory i reakcje. I to wystarczy.",
                body_md: "Stoicy zauważyli, że większość naszego cierpienia bierze się z tego, że walczymy z rzeczami, których nie możemy zmienić.  Pogoda, decyzje innych ludzi, to, czy ktoś Cię pochwali lub skrytykuje – to wszystko jest poza Twoim wpływem. Ale to, co robisz z tym faktem, jest już w Twoich rękach.",
                text_alignment: "left",
                content_color: "#FFFFFF",
                background_color: "#000000",
                is_active: true,
                valid_from: Date(),
                valid_to: nil
            ),
            Slide(
                id: UUID(),
                created_at: Date(),
                updated_at: Date(),
                book_id: 1,
                order_index: 2,
                image_url: URL(string: "https://picsum.photos/seed/2/600/400"),
                video_mp4_url: nil,
                audio_mp3_url: nil,
                eyebrow: "Eyebrow 2",
                title_1: "Sample Title 2",
                title_2: "Subtitle 2",
                lead_md: "Lead markdown text for slide 2.",
                body_md: "Body markdown text for slide 2.",
                text_alignment: "center",
                content_color: "#000000",
                background_color: "#FFFFFF",
                is_active: true,
                valid_from: nil,
                valid_to: nil
            ),
            Slide(
                id: UUID(),
                created_at: Date(),
                updated_at: Date(),
                book_id: 1,
                order_index: 3,
                image_url: URL(string: "https://picsum.photos/seed/3/600/400"),
                video_mp4_url: nil,
                audio_mp3_url: nil,
                eyebrow: "Eyebrow 3",
                title_1: "Sample Title 3",
                title_2: "Subtitle 3",
                lead_md: "Lead markdown text for slide 3.",
                body_md: "Body markdown text for slide 3.",
                text_alignment: "right",
                content_color: "#333333",
                background_color: "#CCCCCC",
                is_active: true,
                valid_from: nil,
                valid_to: nil
            )
        ]
    }
}
